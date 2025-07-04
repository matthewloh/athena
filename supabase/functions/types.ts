export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[];

export type Database = {
  public: {
    Tables: {
      chat_messages: {
        Row: {
          content: string;
          conversation_id: string;
          has_attachments: boolean | null;
          id: string;
          metadata: Json | null;
          sender: string;
          timestamp: string;
          tool_calls: Json | null;
        };
        Insert: {
          content: string;
          conversation_id: string;
          has_attachments?: boolean | null;
          id?: string;
          metadata?: Json | null;
          sender: string;
          timestamp?: string;
          tool_calls?: Json | null;
        };
        Update: {
          content?: string;
          conversation_id?: string;
          has_attachments?: boolean | null;
          id?: string;
          metadata?: Json | null;
          sender?: string;
          timestamp?: string;
          tool_calls?: Json | null;
        };
        Relationships: [
          {
            foreignKeyName: "chat_messages_conversation_id_fkey";
            columns: ["conversation_id"];
            isOneToOne: false;
            referencedRelation: "conversations";
            referencedColumns: ["id"];
          },
        ];
      };
      conversations: {
        Row: {
          created_at: string;
          id: string;
          last_message_snippet: string | null;
          metadata: Json | null;
          title: string | null;
          updated_at: string;
          user_id: string;
        };
        Insert: {
          created_at?: string;
          id?: string;
          last_message_snippet?: string | null;
          metadata?: Json | null;
          title?: string | null;
          updated_at?: string;
          user_id: string;
        };
        Update: {
          created_at?: string;
          id?: string;
          last_message_snippet?: string | null;
          metadata?: Json | null;
          title?: string | null;
          updated_at?: string;
          user_id?: string;
        };
        Relationships: [];
      };
      file_attachments: {
        Row: {
          created_at: string | null;
          file_name: string;
          file_size: number;
          id: string;
          message_id: string;
          mime_type: string;
          storage_path: string;
          thumbnail_path: string | null;
          updated_at: string | null;
          upload_status: string;
        };
        Insert: {
          created_at?: string | null;
          file_name: string;
          file_size: number;
          id?: string;
          message_id: string;
          mime_type: string;
          storage_path: string;
          thumbnail_path?: string | null;
          updated_at?: string | null;
          upload_status?: string;
        };
        Update: {
          created_at?: string | null;
          file_name?: string;
          file_size?: number;
          id?: string;
          message_id?: string;
          mime_type?: string;
          storage_path?: string;
          thumbnail_path?: string | null;
          updated_at?: string | null;
          upload_status?: string;
        };
        Relationships: [
          {
            foreignKeyName: "file_attachments_message_id_fkey";
            columns: ["message_id"];
            isOneToOne: false;
            referencedRelation: "chat_messages";
            referencedColumns: ["id"];
          },
        ];
      };
      notification_history: {
        Row: {
          body: string;
          data: Json | null;
          error_message: string | null;
          id: string;
          sent_at: string | null;
          success: boolean | null;
          title: string;
          type: string;
          user_id: string;
        };
        Insert: {
          body: string;
          data?: Json | null;
          error_message?: string | null;
          id?: string;
          sent_at?: string | null;
          success?: boolean | null;
          title: string;
          type: string;
          user_id: string;
        };
        Update: {
          body?: string;
          data?: Json | null;
          error_message?: string | null;
          id?: string;
          sent_at?: string | null;
          success?: boolean | null;
          title?: string;
          type?: string;
          user_id?: string;
        };
        Relationships: [];
      };
      profiles: {
        Row: {
          avatar_url: string | null;
          fcm_token: string | null;
          full_name: string | null;
          id: string;
          updated_at: string | null;
          username: string | null;
          website: string | null;
        };
        Insert: {
          avatar_url?: string | null;
          fcm_token?: string | null;
          full_name?: string | null;
          id: string;
          updated_at?: string | null;
          username?: string | null;
          website?: string | null;
        };
        Update: {
          avatar_url?: string | null;
          fcm_token?: string | null;
          full_name?: string | null;
          id?: string;
          updated_at?: string | null;
          username?: string | null;
          website?: string | null;
        };
        Relationships: [];
      };
      quiz_items: {
        Row: {
          answer_text: string;
          created_at: string;
          easiness_factor: number;
          id: string;
          interval_days: number;
          item_type: Database["public"]["Enums"]["quiz_item_type"];
          last_reviewed_at: string | null;
          mcq_correct_option_key: string | null;
          mcq_options: Json | null;
          metadata: Json | null;
          next_review_date: string | null;
          question_text: string;
          quiz_id: string;
          repetitions: number;
          updated_at: string;
          user_id: string;
        };
        Insert: {
          answer_text: string;
          created_at?: string;
          easiness_factor?: number;
          id?: string;
          interval_days?: number;
          item_type?: Database["public"]["Enums"]["quiz_item_type"];
          last_reviewed_at?: string | null;
          mcq_correct_option_key?: string | null;
          mcq_options?: Json | null;
          metadata?: Json | null;
          next_review_date?: string | null;
          question_text: string;
          quiz_id: string;
          repetitions?: number;
          updated_at?: string;
          user_id: string;
        };
        Update: {
          answer_text?: string;
          created_at?: string;
          easiness_factor?: number;
          id?: string;
          interval_days?: number;
          item_type?: Database["public"]["Enums"]["quiz_item_type"];
          last_reviewed_at?: string | null;
          mcq_correct_option_key?: string | null;
          mcq_options?: Json | null;
          metadata?: Json | null;
          next_review_date?: string | null;
          question_text?: string;
          quiz_id?: string;
          repetitions?: number;
          updated_at?: string;
          user_id?: string;
        };
        Relationships: [
          {
            foreignKeyName: "quiz_items_quiz_id_fkey";
            columns: ["quiz_id"];
            isOneToOne: false;
            referencedRelation: "quizzes";
            referencedColumns: ["id"];
          },
        ];
      };
      quizzes: {
        Row: {
          created_at: string;
          description: string | null;
          id: string;
          quiz_type: Database["public"]["Enums"]["quiz_type"];
          study_material_id: string | null;
          subject: Database["public"]["Enums"]["subject"] | null;
          title: string;
          updated_at: string;
          user_id: string;
        };
        Insert: {
          created_at?: string;
          description?: string | null;
          id?: string;
          quiz_type?: Database["public"]["Enums"]["quiz_type"];
          study_material_id?: string | null;
          subject?: Database["public"]["Enums"]["subject"] | null;
          title: string;
          updated_at?: string;
          user_id: string;
        };
        Update: {
          created_at?: string;
          description?: string | null;
          id?: string;
          quiz_type?: Database["public"]["Enums"]["quiz_type"];
          study_material_id?: string | null;
          subject?: Database["public"]["Enums"]["subject"] | null;
          title?: string;
          updated_at?: string;
          user_id?: string;
        };
        Relationships: [
          {
            foreignKeyName: "quizzes_study_material_id_fkey";
            columns: ["study_material_id"];
            isOneToOne: false;
            referencedRelation: "study_materials";
            referencedColumns: ["id"];
          },
        ];
      };
      review_responses: {
        Row: {
          difficulty_rating: Database["public"]["Enums"]["difficulty_rating"];
          id: string;
          is_correct: boolean | null;
          new_easiness_factor: number | null;
          new_interval_days: number | null;
          new_next_review_date: string | null;
          new_repetitions: number | null;
          previous_easiness_factor: number | null;
          previous_interval_days: number | null;
          previous_repetitions: number | null;
          quiz_item_id: string;
          responded_at: string;
          response_time_seconds: number | null;
          session_id: string;
          user_answer: string | null;
          user_id: string;
        };
        Insert: {
          difficulty_rating: Database["public"]["Enums"]["difficulty_rating"];
          id?: string;
          is_correct?: boolean | null;
          new_easiness_factor?: number | null;
          new_interval_days?: number | null;
          new_next_review_date?: string | null;
          new_repetitions?: number | null;
          previous_easiness_factor?: number | null;
          previous_interval_days?: number | null;
          previous_repetitions?: number | null;
          quiz_item_id: string;
          responded_at?: string;
          response_time_seconds?: number | null;
          session_id: string;
          user_answer?: string | null;
          user_id: string;
        };
        Update: {
          difficulty_rating?: Database["public"]["Enums"]["difficulty_rating"];
          id?: string;
          is_correct?: boolean | null;
          new_easiness_factor?: number | null;
          new_interval_days?: number | null;
          new_next_review_date?: string | null;
          new_repetitions?: number | null;
          previous_easiness_factor?: number | null;
          previous_interval_days?: number | null;
          previous_repetitions?: number | null;
          quiz_item_id?: string;
          responded_at?: string;
          response_time_seconds?: number | null;
          session_id?: string;
          user_answer?: string | null;
          user_id?: string;
        };
        Relationships: [
          {
            foreignKeyName: "review_responses_quiz_item_id_fkey";
            columns: ["quiz_item_id"];
            isOneToOne: false;
            referencedRelation: "quiz_items";
            referencedColumns: ["id"];
          },
          {
            foreignKeyName: "review_responses_session_id_fkey";
            columns: ["session_id"];
            isOneToOne: false;
            referencedRelation: "review_sessions";
            referencedColumns: ["id"];
          },
        ];
      };
      review_sessions: {
        Row: {
          average_difficulty: number | null;
          completed_at: string | null;
          completed_items: number;
          correct_responses: number;
          id: string;
          quiz_id: string | null;
          session_duration_seconds: number | null;
          session_type: Database["public"]["Enums"]["session_type"];
          started_at: string;
          status: Database["public"]["Enums"]["session_status"];
          total_items: number;
          user_id: string;
        };
        Insert: {
          average_difficulty?: number | null;
          completed_at?: string | null;
          completed_items?: number;
          correct_responses?: number;
          id?: string;
          quiz_id?: string | null;
          session_duration_seconds?: number | null;
          session_type?: Database["public"]["Enums"]["session_type"];
          started_at?: string;
          status?: Database["public"]["Enums"]["session_status"];
          total_items?: number;
          user_id: string;
        };
        Update: {
          average_difficulty?: number | null;
          completed_at?: string | null;
          completed_items?: number;
          correct_responses?: number;
          id?: string;
          quiz_id?: string | null;
          session_duration_seconds?: number | null;
          session_type?: Database["public"]["Enums"]["session_type"];
          started_at?: string;
          status?: Database["public"]["Enums"]["session_status"];
          total_items?: number;
          user_id?: string;
        };
        Relationships: [
          {
            foreignKeyName: "review_sessions_quiz_id_fkey";
            columns: ["quiz_id"];
            isOneToOne: false;
            referencedRelation: "quizzes";
            referencedColumns: ["id"];
          },
        ];
      };
      study_goals: {
        Row: {
          created_at: string;
          description: string | null;
          id: string;
          is_completed: boolean;
          progress: number;
          subject: string | null;
          target_date: string | null;
          title: string;
          updated_at: string;
          user_id: string;
        };
        Insert: {
          created_at?: string;
          description?: string | null;
          id?: string;
          is_completed?: boolean;
          progress?: number;
          subject?: string | null;
          target_date?: string | null;
          title: string;
          updated_at?: string;
          user_id: string;
        };
        Update: {
          created_at?: string;
          description?: string | null;
          id?: string;
          is_completed?: boolean;
          progress?: number;
          subject?: string | null;
          target_date?: string | null;
          title?: string;
          updated_at?: string;
          user_id?: string;
        };
        Relationships: [];
      };
      study_materials: {
        Row: {
          content_type: Database["public"]["Enums"]["content_type"];
          created_at: string;
          description: string | null;
          file_storage_path: string | null;
          has_ai_summary: boolean;
          id: string;
          ocr_extracted_text: string | null;
          original_content_text: string | null;
          subject: Database["public"]["Enums"]["subject"] | null;
          summary_text: string | null;
          title: string;
          updated_at: string;
          user_id: string;
        };
        Insert: {
          content_type: Database["public"]["Enums"]["content_type"];
          created_at?: string;
          description?: string | null;
          file_storage_path?: string | null;
          has_ai_summary?: boolean;
          id?: string;
          ocr_extracted_text?: string | null;
          original_content_text?: string | null;
          subject?: Database["public"]["Enums"]["subject"] | null;
          summary_text?: string | null;
          title: string;
          updated_at?: string;
          user_id: string;
        };
        Update: {
          content_type?: Database["public"]["Enums"]["content_type"];
          created_at?: string;
          description?: string | null;
          file_storage_path?: string | null;
          has_ai_summary?: boolean;
          id?: string;
          ocr_extracted_text?: string | null;
          original_content_text?: string | null;
          subject?: Database["public"]["Enums"]["subject"] | null;
          summary_text?: string | null;
          title?: string;
          updated_at?: string;
          user_id?: string;
        };
        Relationships: [];
      };
      study_sessions: {
        Row: {
          actual_duration_minutes: number | null;
          created_at: string;
          end_time: string;
          id: string;
          linked_material_id: string | null;
          notes: string | null;
          reminder_offset_minutes: number | null;
          start_time: string;
          status: Database["public"]["Enums"]["study_session_status"];
          study_goal_id: string | null;
          subject: string | null;
          title: string;
          updated_at: string;
          user_id: string;
        };
        Insert: {
          actual_duration_minutes?: number | null;
          created_at?: string;
          end_time: string;
          id?: string;
          linked_material_id?: string | null;
          notes?: string | null;
          reminder_offset_minutes?: number | null;
          start_time: string;
          status?: Database["public"]["Enums"]["study_session_status"];
          study_goal_id?: string | null;
          subject?: string | null;
          title: string;
          updated_at?: string;
          user_id: string;
        };
        Update: {
          actual_duration_minutes?: number | null;
          created_at?: string;
          end_time?: string;
          id?: string;
          linked_material_id?: string | null;
          notes?: string | null;
          reminder_offset_minutes?: number | null;
          start_time?: string;
          status?: Database["public"]["Enums"]["study_session_status"];
          study_goal_id?: string | null;
          subject?: string | null;
          title?: string;
          updated_at?: string;
          user_id?: string;
        };
        Relationships: [
          {
            foreignKeyName: "study_sessions_linked_material_id_fkey";
            columns: ["linked_material_id"];
            isOneToOne: false;
            referencedRelation: "study_materials";
            referencedColumns: ["id"];
          },
          {
            foreignKeyName: "study_sessions_study_goal_id_fkey";
            columns: ["study_goal_id"];
            isOneToOne: false;
            referencedRelation: "study_goals";
            referencedColumns: ["id"];
          },
        ];
      };
    };
    Views: {
      [_ in never]: never;
    };
    Functions: {
      get_conversations_with_stats: {
        Args: { user_uuid: string };
        Returns: {
          id: string;
          user_id: string;
          title: string;
          created_at: string;
          updated_at: string;
          last_message_snippet: string;
          message_count: number;
          metadata: Json;
        }[];
      };
      validate_mcq_options: {
        Args: { options: Json };
        Returns: boolean;
      };
    };
    Enums: {
      content_type: "typedText" | "textFile" | "imageFile";
      difficulty_rating: "forgot" | "hard" | "good" | "easy";
      quiz_item_type: "flashcard" | "multipleChoice";
      quiz_type: "flashcard" | "multipleChoice";
      session_status: "active" | "completed" | "abandoned";
      session_type: "mixed" | "dueOnly" | "newOnly";
      study_session_status:
        | "scheduled"
        | "inProgress"
        | "completed"
        | "missed"
        | "cancelled";
      subject:
        | "mathematics"
        | "physics"
        | "chemistry"
        | "biology"
        | "computerScience"
        | "engineering"
        | "statistics"
        | "dataScience"
        | "informationTechnology"
        | "cybersecurity"
        | "englishLiterature"
        | "englishLanguage"
        | "spanish"
        | "french"
        | "german"
        | "chinese"
        | "japanese"
        | "linguistics"
        | "creativeWriting"
        | "history"
        | "geography"
        | "psychology"
        | "sociology"
        | "politicalScience"
        | "economics"
        | "anthropology"
        | "internationalRelations"
        | "philosophy"
        | "ethics"
        | "businessStudies"
        | "marketing"
        | "finance"
        | "accounting"
        | "management"
        | "humanResources"
        | "operationsManagement"
        | "entrepreneurship"
        | "art"
        | "music"
        | "drama"
        | "filmStudies"
        | "photography"
        | "graphicDesign"
        | "architecture"
        | "medicine"
        | "nursing"
        | "publicHealth"
        | "nutrition"
        | "physicalEducation"
        | "sportsScience"
        | "law"
        | "criminalJustice"
        | "legalStudies"
        | "environmentalScience"
        | "geology"
        | "climateScience"
        | "marineBiology"
        | "education"
        | "pedagogy"
        | "educationalPsychology";
    };
    CompositeTypes: {
      [_ in never]: never;
    };
  };
};

type DefaultSchema = Database[Extract<keyof Database, "public">];

export type Tables<
  DefaultSchemaTableNameOrOptions extends
    | keyof (DefaultSchema["Tables"] & DefaultSchema["Views"])
    | { schema: keyof Database },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof Database;
  } ? keyof (
      & Database[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
      & Database[DefaultSchemaTableNameOrOptions["schema"]]["Views"]
    )
    : never = never,
> = DefaultSchemaTableNameOrOptions extends { schema: keyof Database } ? (
    & Database[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    & Database[DefaultSchemaTableNameOrOptions["schema"]]["Views"]
  )[TableName] extends {
    Row: infer R;
  } ? R
  : never
  : DefaultSchemaTableNameOrOptions extends keyof (
    & DefaultSchema["Tables"]
    & DefaultSchema["Views"]
  ) ? (
      & DefaultSchema["Tables"]
      & DefaultSchema["Views"]
    )[DefaultSchemaTableNameOrOptions] extends {
      Row: infer R;
    } ? R
    : never
  : never;

export type TablesInsert<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof Database },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof Database;
  } ? keyof Database[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = DefaultSchemaTableNameOrOptions extends { schema: keyof Database }
  ? Database[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][
    TableName
  ] extends {
    Insert: infer I;
  } ? I
  : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
      Insert: infer I;
    } ? I
    : never
  : never;

export type TablesUpdate<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof Database },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof Database;
  } ? keyof Database[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = DefaultSchemaTableNameOrOptions extends { schema: keyof Database }
  ? Database[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][
    TableName
  ] extends {
    Update: infer U;
  } ? U
  : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
      Update: infer U;
    } ? U
    : never
  : never;

export type Enums<
  DefaultSchemaEnumNameOrOptions extends
    | keyof DefaultSchema["Enums"]
    | { schema: keyof Database },
  EnumName extends DefaultSchemaEnumNameOrOptions extends {
    schema: keyof Database;
  } ? keyof Database[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"]
    : never = never,
> = DefaultSchemaEnumNameOrOptions extends { schema: keyof Database }
  ? Database[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"][EnumName]
  : DefaultSchemaEnumNameOrOptions extends keyof DefaultSchema["Enums"]
    ? DefaultSchema["Enums"][DefaultSchemaEnumNameOrOptions]
  : never;

export type CompositeTypes<
  PublicCompositeTypeNameOrOptions extends
    | keyof DefaultSchema["CompositeTypes"]
    | { schema: keyof Database },
  CompositeTypeName extends PublicCompositeTypeNameOrOptions extends {
    schema: keyof Database;
  }
    ? keyof Database[PublicCompositeTypeNameOrOptions["schema"]][
      "CompositeTypes"
    ]
    : never = never,
> = PublicCompositeTypeNameOrOptions extends { schema: keyof Database }
  ? Database[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"][
    CompositeTypeName
  ]
  : PublicCompositeTypeNameOrOptions extends
    keyof DefaultSchema["CompositeTypes"]
    ? DefaultSchema["CompositeTypes"][PublicCompositeTypeNameOrOptions]
  : never;

export const Constants = {
  public: {
    Enums: {
      content_type: ["typedText", "textFile", "imageFile"],
      difficulty_rating: ["forgot", "hard", "good", "easy"],
      quiz_item_type: ["flashcard", "multipleChoice"],
      quiz_type: ["flashcard", "multipleChoice"],
      session_status: ["active", "completed", "abandoned"],
      session_type: ["mixed", "dueOnly", "newOnly"],
      study_session_status: [
        "scheduled",
        "inProgress",
        "completed",
        "missed",
        "cancelled",
      ],
      subject: [
        "mathematics",
        "physics",
        "chemistry",
        "biology",
        "computerScience",
        "engineering",
        "statistics",
        "dataScience",
        "informationTechnology",
        "cybersecurity",
        "englishLiterature",
        "englishLanguage",
        "spanish",
        "french",
        "german",
        "chinese",
        "japanese",
        "linguistics",
        "creativeWriting",
        "history",
        "geography",
        "psychology",
        "sociology",
        "politicalScience",
        "economics",
        "anthropology",
        "internationalRelations",
        "philosophy",
        "ethics",
        "businessStudies",
        "marketing",
        "finance",
        "accounting",
        "management",
        "humanResources",
        "operationsManagement",
        "entrepreneurship",
        "art",
        "music",
        "drama",
        "filmStudies",
        "photography",
        "graphicDesign",
        "architecture",
        "medicine",
        "nursing",
        "publicHealth",
        "nutrition",
        "physicalEducation",
        "sportsScience",
        "law",
        "criminalJustice",
        "legalStudies",
        "environmentalScience",
        "geology",
        "climateScience",
        "marineBiology",
        "education",
        "pedagogy",
        "educationalPsychology",
      ],
    },
  },
} as const;
