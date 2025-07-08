import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

interface StudyMaterialsRequest {
  user_id?: string
  subject?: string
  search_query?: string
  has_ai_summary?: boolean
  content_type?: 'typedText' | 'textFile' | 'imageFile'
  limit?: number
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

    const requestBody: StudyMaterialsRequest = await req.json()
    
    // Build query
    let query = supabase
      .from('study_materials')
      .select(`
        id,
        title,
        description,
        subject,
        content_type,
        original_content_text,
        ocr_extracted_text,
        summary_text,
        has_ai_summary,
        created_at,
        updated_at
      `)
      .eq('user_id', user.id)
      .order('created_at', { ascending: false })

    // Apply filters
    if (requestBody.subject) {
      query = query.eq('subject', requestBody.subject)
    }
    
    if (requestBody.content_type) {
      query = query.eq('content_type', requestBody.content_type)
    }
    
    if (requestBody.has_ai_summary !== undefined) {
      query = query.eq('has_ai_summary', requestBody.has_ai_summary)
    }

    // Apply search if provided
    if (requestBody.search_query) {
      query = query.or(`title.ilike.%${requestBody.search_query}%,description.ilike.%${requestBody.search_query}%,summary_text.ilike.%${requestBody.search_query}%`)
    }

    // Apply limit
    const limit = requestBody.limit || 10
    query = query.limit(limit)

    const { data: materials, error } = await query

    if (error) {
      console.error('Error fetching study materials:', error)
      return new Response(
        JSON.stringify({ error: 'Failed to fetch study materials' }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Enhance materials with summary statistics
    const enhancedMaterials = materials?.map(material => ({
      ...material,
      content_preview: material.summary_text 
        ? material.summary_text.substring(0, 200) + '...'
        : material.original_content_text?.substring(0, 200) + '...' || 
          material.ocr_extracted_text?.substring(0, 200) + '...' || 
          'No content preview available',
      has_content: !!(material.original_content_text || material.ocr_extracted_text),
      content_length: (material.original_content_text || material.ocr_extracted_text || '').length
    }))

    // Get related quizzes count for each material
    const materialIds = materials?.map(m => m.id) || []
    let quizCounts = {}
    
    if (materialIds.length > 0) {
      const { data: quizData } = await supabase
        .from('quizzes')
        .select('study_material_id, id')
        .in('study_material_id', materialIds)
      
      quizCounts = quizData?.reduce((acc, quiz) => {
        acc[quiz.study_material_id] = (acc[quiz.study_material_id] || 0) + 1
        return acc
      }, {} as Record<string, number>) || {}
    }

    const finalMaterials = enhancedMaterials?.map(material => ({
      ...material,
      related_quiz_count: quizCounts[material.id] || 0
    }))

    // Generate navigation actions for the materials
    const navigationActions = [
      // View all materials action
      {
        id: 'view_all_materials',
        label: 'View All Materials',
        description: requestBody.subject ? `View ${requestBody.subject} materials` : 'Browse your study materials',
        routeName: 'materials',
        queryParameters: requestBody.subject ? { subject: requestBody.subject } : null,
        icon: '📚',
        type: 'primary'
      },
      // Individual material actions (limit to top 3)
      ...(finalMaterials?.slice(0, 3).map(material => ({
        id: `view_material_${material.id}`,
        label: material.title,
        description: 'View material details',
        routeName: 'material-detail',
        pathParameters: { materialId: material.id },
        icon: '📄',
        type: 'material'
      })) || []),
      // Create quiz actions for materials with content
      ...(finalMaterials?.slice(0, 2).filter(m => m.has_content).map(material => ({
        id: `create_quiz_${material.id}`,
        label: `Create Quiz: ${material.title}`,
        description: 'Generate quiz questions from this material',
        routeName: 'create-quiz',
        queryParameters: { studyMaterialId: material.id },
        icon: '❓',
        type: 'quiz'
      })) || []),
      // Add material action if not too many results
      ...(finalMaterials && finalMaterials.length < 5 ? [{
        id: 'add_material',
        label: 'Add Study Material',
        description: 'Upload or create new study material',
        routeName: 'add-edit-material',
        icon: '➕',
        type: 'action'
      }] : [])
    ]

    return new Response(
      JSON.stringify({
        materials: finalMaterials,
        total_count: finalMaterials?.length || 0,
        search_performed: !!requestBody.search_query,
        filters_applied: {
          subject: requestBody.subject || null,
          content_type: requestBody.content_type || null,
          has_ai_summary: requestBody.has_ai_summary
        },
        navigation_actions: navigationActions
      }),
      { 
        status: 200, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )

  } catch (error) {
    console.error('Error in get-study-materials function:', error)
    return new Response(
      JSON.stringify({ error: 'Internal server error' }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
}) 