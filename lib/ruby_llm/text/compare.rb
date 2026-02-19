module RubyLLM
  module Text
    module Compare
      def self.call(text1, text2, comparison_type: :similarity, model: nil, **options)
        Validation.validate_text!(text1, param_name: "text1")
        Validation.validate_text!(text2, param_name: "text2")
        model ||= RubyLLM::Text.config.model_for(:compare)

        prompt = build_prompt(text1, text2, comparison_type: comparison_type)
        schema = build_comparison_schema(comparison_type)
        response = Base.call_llm(prompt, model: model, schema: schema, **options)

        begin
          result = JSON.parse(Base.clean_json_response(response))
        rescue JSON::ParserError
          # Fallback: if JSON parsing fails, return basic structured response
          result = {
            "similarity" => nil,
            "comparison_type" => comparison_type.to_s,
            "error" => "Failed to parse comparison result"
          }
        end

        # Convert similarity to float when present
        if result.key?("similarity") && !result["similarity"].nil?
          result["similarity"] = result["similarity"].to_f
        end

        result
      end

      private

      def self.build_prompt(text1, text2, comparison_type:)
        case comparison_type
        when :similarity
          comparison_instruction = <<~INSTRUCTION
            Compare the two texts and provide:
            - A similarity score from 0 to 1 (where 1 is identical and 0 is completely different)
            - The type of similarity detected (semantic, structural, topical, etc.)
            - A brief summary of what makes them similar or different

            Focus on semantic similarity - texts with the same meaning should score high even if worded differently.
          INSTRUCTION
        when :detailed
          comparison_instruction = <<~INSTRUCTION
            Provide a detailed comparison including:
            - Overall similarity score from 0 to 1
            - Specific differences between the texts (tone, style, content, structure, etc.)
            - Common elements or themes found in both texts
            - A summary of the key similarities and differences

            Analyze style, tone, content, structure, and intent.
          INSTRUCTION
        when :changes
          comparison_instruction = <<~INSTRUCTION
            Analyze the texts as if the second text is a revision of the first and provide:
            - Overall similarity score from 0 to 1
            - Types of changes made (additions, deletions, modifications, restructuring)
            - Specific examples of what was changed
            - Assessment of whether the changes improve or alter the content significantly

            Focus on tracking edits and revisions between the versions.
          INSTRUCTION
        else
          comparison_instruction = build_prompt(text1, text2, comparison_type: :similarity)
        end

        <<~PROMPT
          Compare the following two texts:

          #{comparison_instruction}

          Text 1:
          #{text1}

          Text 2:
          #{text2}
        PROMPT
      end

      def self.build_comparison_schema(comparison_type)
        base_properties = {
          similarity: { type: "number", minimum: 0, maximum: 1 },
          comparison_type: { type: "string" }
        }

        case comparison_type
        when :similarity
          base_properties.merge!({
            similarity_type: { type: "string" },
            summary: { type: "string" }
          })
        when :detailed
          base_properties.merge!({
            differences: {
              type: "array",
              items: { type: "string" }
            },
            commonalities: {
              type: "array",
              items: { type: "string" }
            },
            summary: { type: "string" }
          })
        when :changes
          base_properties.merge!({
            change_types: {
              type: "array",
              items: { type: "string" }
            },
            examples: {
              type: "array",
              items: { type: "string" }
            },
            assessment: { type: "string" }
          })
        end

        {
          type: "object",
          properties: base_properties,
          required: [ "similarity", "comparison_type" ]
        }
      end
    end
  end
end
