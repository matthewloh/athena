import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

interface ContentSearchRequest {
  query: string
  material_id?: string
  subject?: string
  max_results?: number
  include_context?: boolean
}

interface SearchResult {
  material_id: string
  material_title: string
  subject: string
  content_type: string
  matches: Array<{
    text: string
    context: string
    relevance_score: number
  }>
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

    const { query, material_id, subject, max_results = 5, include_context = true }: ContentSearchRequest = await req.json()
    
    if (!query || query.trim().length < 2) {
      return new Response(
        JSON.stringify({ error: 'Query must be at least 2 characters long' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Build base query for materials
    let materialsQuery = supabase
      .from('study_materials')
      .select(`
        id,
        title,
        subject,
        content_type,
        original_content_text,
        ocr_extracted_text,
        summary_text,
        has_ai_summary
      `)
      .eq('user_id', user.id)

    // Apply filters
    if (material_id) {
      materialsQuery = materialsQuery.eq('id', material_id)
    }
    
    if (subject) {
      materialsQuery = materialsQuery.eq('subject', subject)
    }

    const { data: materials, error: materialsError } = await materialsQuery

    if (materialsError) {
      console.error('Error fetching materials:', materialsError)
      return new Response(
        JSON.stringify({ error: 'Failed to fetch materials' }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    if (!materials || materials.length === 0) {
      return new Response(
        JSON.stringify({
          results: [],
          total_matches: 0,
          query_used: query,
          searched_materials: 0
        }),
        { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Perform content search
    const searchResults: SearchResult[] = []
    const searchTerms = query.toLowerCase().split(/\s+/).filter(term => term.length > 1)

    for (const material of materials) {
      // Combine all available text content
      const contentSources = [
        { type: 'original', text: material.original_content_text },
        { type: 'ocr', text: material.ocr_extracted_text },
        { type: 'summary', text: material.summary_text }
      ].filter(source => source.text && source.text.trim().length > 0)

      const matches: Array<{ text: string; context: string; relevance_score: number }> = []

      for (const source of contentSources) {
        const text = source.text!.toLowerCase()
        
        // Find matches for each search term
        for (const term of searchTerms) {
          const termMatches = []
          let index = text.indexOf(term)
          
          while (index !== -1 && termMatches.length < 3) { // Limit matches per term
            // Extract context around the match
            const contextStart = Math.max(0, index - 100)
            const contextEnd = Math.min(text.length, index + term.length + 100)
            const context = source.text!.substring(contextStart, contextEnd)
            
            // Calculate relevance score based on various factors
            let relevanceScore = 1.0
            
            // Boost score for exact matches
            if (text.substring(index, index + term.length) === term) {
              relevanceScore += 0.5
            }
            
            // Boost score for matches in summary (more important)
            if (source.type === 'summary') {
              relevanceScore += 0.3
            }
            
            // Boost score for matches near start of content
            if (index < text.length * 0.1) {
              relevanceScore += 0.2
            }
            
            termMatches.push({
              text: term,
              context: context.trim(),
              relevance_score: relevanceScore
            })
            
            index = text.indexOf(term, index + 1)
          }
          
          matches.push(...termMatches)
        }
      }

      // Sort matches by relevance and limit results
      matches.sort((a, b) => b.relevance_score - a.relevance_score)
      const topMatches = matches.slice(0, max_results)

      if (topMatches.length > 0) {
        searchResults.push({
          material_id: material.id,
          material_title: material.title,
          subject: material.subject || 'Unknown',
          content_type: material.content_type,
          matches: topMatches
        })
      }
    }

    // Sort results by total relevance score
    searchResults.sort((a, b) => {
      const scoreA = a.matches.reduce((sum, match) => sum + match.relevance_score, 0)
      const scoreB = b.matches.reduce((sum, match) => sum + match.relevance_score, 0)
      return scoreB - scoreA
    })

    const totalMatches = searchResults.reduce((sum, result) => sum + result.matches.length, 0)

    return new Response(
      JSON.stringify({
        results: searchResults.slice(0, max_results),
        total_matches: totalMatches,
        query_used: query,
        searched_materials: materials.length,
        search_terms: searchTerms
      }),
      { 
        status: 200, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )

  } catch (error) {
    console.error('Error in search-material-content function:', error)
    return new Response(
      JSON.stringify({ error: 'Internal server error' }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
}) 