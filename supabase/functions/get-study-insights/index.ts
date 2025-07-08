import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

interface StudyInsightsRequest {
  include_goals?: boolean
  include_materials?: boolean
  include_quizzes?: boolean
  include_sessions?: boolean
  days_back?: number
}

serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
      {
        global: {
          headers: { Authorization: req.headers.get('Authorization')! },
        },
      }
    )

    // Get current user
    const { data: { user }, error: userError } = await supabase.auth.getUser()
    if (userError || !user) {
      return new Response(
        JSON.stringify({ error: 'Unauthorized' }),
        { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    const {
      include_goals = true,
      include_materials = true,
      include_quizzes = true,
      include_sessions = true,
      days_back = 30
    }: StudyInsightsRequest = await req.json().catch(() => ({}))

    const insights: any = {
      user_id: user.id,
      generated_at: new Date().toISOString(),
      period_days: days_back
    }

    const dateThreshold = new Date()
    dateThreshold.setDate(dateThreshold.getDate() - days_back)

    // Study Goals Insights
    if (include_goals) {
      const { data: goals } = await supabase
        .from('study_goals')
        .select('*')
        .eq('user_id', user.id)

      const { data: recentGoals } = await supabase
        .from('study_goals')
        .select('*')
        .eq('user_id', user.id)
        .gte('created_at', dateThreshold.toISOString())

      insights.goals = {
        total_count: goals?.length || 0,
        completed_count: goals?.filter(g => g.is_completed).length || 0,
        in_progress_count: goals?.filter(g => !g.is_completed && g.progress > 0).length || 0,
        not_started_count: goals?.filter(g => !g.is_completed && g.progress === 0).length || 0,
        average_progress: goals?.length ? goals.reduce((sum, g) => sum + parseFloat(g.progress), 0) / goals.length : 0,
        recent_activity: recentGoals?.length || 0,
        by_subject: goals?.reduce((acc, goal) => {
          const subject = goal.subject || 'Other'
          acc[subject] = (acc[subject] || 0) + 1
          return acc
        }, {} as Record<string, number>) || {},
        by_priority: goals?.reduce((acc, goal) => {
          acc[goal.priority_level] = (acc[goal.priority_level] || 0) + 1
          return acc
        }, {} as Record<string, number>) || {},
        highest_priority_incomplete: goals?.filter(g => !g.is_completed && g.priority_level === 'high') || []
      }
    }

    // Study Materials Insights
    if (include_materials) {
      const { data: materials } = await supabase
        .from('study_materials')
        .select('*')
        .eq('user_id', user.id)

      const { data: recentMaterials } = await supabase
        .from('study_materials')
        .select('*')
        .eq('user_id', user.id)
        .gte('created_at', dateThreshold.toISOString())

      insights.materials = {
        total_count: materials?.length || 0,
        with_summaries: materials?.filter(m => m.has_ai_summary).length || 0,
        recent_additions: recentMaterials?.length || 0,
        by_subject: materials?.reduce((acc, material) => {
          const subject = material.subject || 'Other'
          acc[subject] = (acc[subject] || 0) + 1
          return acc
        }, {} as Record<string, number>) || {},
        by_content_type: materials?.reduce((acc, material) => {
          acc[material.content_type] = (acc[material.content_type] || 0) + 1
          return acc
        }, {} as Record<string, number>) || {},
        total_content_length: materials?.reduce((sum, m) => 
          sum + (m.original_content_text?.length || 0) + (m.ocr_extracted_text?.length || 0), 0) || 0
      }
    }

    // Quiz & Review Insights
    if (include_quizzes) {
      const { data: quizzes } = await supabase
        .from('quizzes')
        .select(`
          *,
          quiz_items(*)
        `)
        .eq('user_id', user.id)

      const { data: recentSessions } = await supabase
        .from('review_sessions')
        .select('*')
        .eq('user_id', user.id)
        .gte('started_at', dateThreshold.toISOString())

      const { data: reviewResponses } = await supabase
        .from('review_responses')
        .select('*')
        .eq('user_id', user.id)
        .gte('responded_at', dateThreshold.toISOString())

      const totalItems = quizzes?.reduce((sum, quiz) => sum + (quiz.quiz_items?.length || 0), 0) || 0
      const reviewedItems = reviewResponses?.length || 0
      const correctResponses = reviewResponses?.filter(r => r.is_correct).length || 0

      insights.quizzes = {
        total_quizzes: quizzes?.length || 0,
        total_items: totalItems,
        recent_review_sessions: recentSessions?.length || 0,
        recent_responses: reviewedItems,
        accuracy_rate: reviewedItems > 0 ? (correctResponses / reviewedItems) : 0,
        by_quiz_type: quizzes?.reduce((acc, quiz) => {
          acc[quiz.quiz_type] = (acc[quiz.quiz_type] || 0) + 1
          return acc
        }, {} as Record<string, number>) || {},
        by_subject: quizzes?.reduce((acc, quiz) => {
          const subject = quiz.subject || 'Other'
          acc[subject] = (acc[subject] || 0) + 1
          return acc
        }, {} as Record<string, number>) || {},
        items_due_today: 0, // Will calculate based on next_review_date
        average_easiness: quizzes?.reduce((sum, quiz) => {
          const items = quiz.quiz_items || []
          const avgEasiness = items.length ? items.reduce((s, item) => s + parseFloat(item.easiness_factor), 0) / items.length : 2.5
          return sum + avgEasiness
        }, 0) / (quizzes?.length || 1) || 2.5
      }

      // Calculate items due today
      const today = new Date().toISOString().split('T')[0]
      const { data: dueItems } = await supabase
        .from('quiz_items')
        .select('id')
        .eq('user_id', user.id)
        .lte('next_review_date', today)

      insights.quizzes.items_due_today = dueItems?.length || 0
    }

    // Study Sessions Insights (if we have session data)
    if (include_sessions) {
      const { data: sessions } = await supabase
        .from('study_sessions')
        .select('*')
        .eq('user_id', user.id)

      const { data: recentSessions } = await supabase
        .from('study_sessions')
        .select('*')
        .eq('user_id', user.id)
        .gte('created_at', dateThreshold.toISOString())

      insights.sessions = {
        total_sessions: sessions?.length || 0,
        completed_sessions: sessions?.filter(s => s.status === 'completed').length || 0,
        missed_sessions: sessions?.filter(s => s.status === 'missed').length || 0,
        recent_sessions: recentSessions?.length || 0,
        completion_rate: sessions?.length ? 
          (sessions.filter(s => s.status === 'completed').length / sessions.length) : 0,
        total_study_time: sessions?.reduce((sum, s) => sum + (s.actual_duration_minutes || 0), 0) || 0,
        average_session_length: sessions?.filter(s => s.actual_duration_minutes).length ? 
          sessions.filter(s => s.actual_duration_minutes).reduce((sum, s) => sum + s.actual_duration_minutes, 0) / 
          sessions.filter(s => s.actual_duration_minutes).length : 0
      }
    }

    // Generate smart recommendations
    const recommendations = []

    if (insights.goals?.not_started_count > 0) {
      recommendations.push({
        type: 'goal_activation',
        priority: 'medium',
        message: `You have ${insights.goals.not_started_count} goals that haven't been started yet. Consider breaking them into smaller, actionable steps.`
      })
    }

    if (insights.quizzes?.items_due_today > 0) {
      recommendations.push({
        type: 'review_reminder',
        priority: 'high',
        message: `You have ${insights.quizzes.items_due_today} quiz items due for review today. Regular review helps with long-term retention!`
      })
    }

    if (insights.quizzes?.accuracy_rate < 0.7 && insights.quizzes?.recent_responses > 5) {
      recommendations.push({
        type: 'study_strategy',
        priority: 'medium',
        message: `Your recent quiz accuracy is ${Math.round(insights.quizzes.accuracy_rate * 100)}%. Consider reviewing difficult concepts or adjusting your study approach.`
      })
    }

    if (insights.materials?.total_count > insights.materials?.with_summaries) {
      const unsummarized = insights.materials.total_count - insights.materials.with_summaries
      recommendations.push({
        type: 'content_organization',
        priority: 'low',
        message: `You have ${unsummarized} study materials without AI summaries. Generating summaries can help with quick review and understanding.`
      })
    }

    insights.recommendations = recommendations

    // Generate contextual navigation actions based on insights
    const navigationActions = []

    // Always include progress insights
    navigationActions.push({
      id: 'view_progress_insights',
      label: 'Progress Insights',
      description: 'View detailed study analytics',
      routeName: 'progress-insights',
      icon: '📊',
      type: 'insights'
    })

    // Materials-related actions
    if (insights.materials?.total_count > 0) {
      navigationActions.push({
        id: 'view_all_materials',
        label: 'View All Materials',
        description: `Browse your ${insights.materials.total_count} study materials`,
        routeName: 'materials',
        icon: '📚',
        type: 'primary'
      })

      // Suggest materials by most common subject
      const topSubject = Object.keys(insights.materials.by_subject || {})
        .reduce((a, b) => (insights.materials.by_subject[a] || 0) > (insights.materials.by_subject[b] || 0) ? a : b, '')
      
      if (topSubject) {
        navigationActions.push({
          id: `view_${topSubject.toLowerCase()}_materials`,
          label: `${topSubject} Materials`,
          description: `View your ${insights.materials.by_subject[topSubject]} ${topSubject} materials`,
          routeName: 'materials',
          queryParameters: { subject: topSubject },
          icon: '📄',
          type: 'material'
        })
      }
    }

    // Quiz-related actions
    if (insights.quizzes?.total_quizzes > 0) {
      navigationActions.push({
        id: 'view_all_quizzes',
        label: 'View All Quizzes',
        description: `Browse your ${insights.quizzes.total_quizzes} quiz sets`,
        routeName: 'review',
        icon: '📋',
        type: 'primary'
      })

      // If items are due for review
      if (insights.quizzes.items_due_today > 0) {
        navigationActions.push({
          id: 'start_due_review',
          label: 'Review Due Items',
          description: `Start reviewing ${insights.quizzes.items_due_today} items due today`,
          routeName: 'review',
          queryParameters: { filter: 'due' },
          icon: '🎯',
          type: 'review'
        })
      }
    }

    // Study planner action
    navigationActions.push({
      id: 'view_planner',
      label: 'Study Planner',
      description: 'Plan your study sessions',
      routeName: 'planner',
      icon: '📅',
      type: 'planner'
    })

    // Material creation if few materials
    if ((insights.materials?.total_count || 0) < 5) {
      navigationActions.push({
        id: 'add_material',
        label: 'Add Study Material',
        description: 'Upload or create new study material',
        routeName: 'add-edit-material',
        icon: '➕',
        type: 'action'
      })
    }

    // Quiz creation if materials exist but few quizzes
    if ((insights.materials?.total_count || 0) > 0 && (insights.quizzes?.total_quizzes || 0) < 3) {
      navigationActions.push({
        id: 'create_quiz',
        label: 'Create Quiz',
        description: 'Generate quiz questions from your materials',
        routeName: 'create-quiz',
        icon: '❓',
        type: 'quiz'
      })
    }

    const response = {
      ...insights,
      navigation_actions: navigationActions
    }

    return new Response(
      JSON.stringify(response),
      { 
        status: 200, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )

  } catch (error) {
    console.error('Error in get-study-insights function:', error)
    return new Response(
      JSON.stringify({ error: 'Internal server error' }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
}) 