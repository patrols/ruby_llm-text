module RubyLLM
  module Text
    module Grammar
      def self.call(text, explain: false, preserve_style: false, model: nil, **options)
        model ||= RubyLLM::Text.config.model_for(:grammar)

        prompt = build_prompt(text, explain: explain, preserve_style: preserve_style)

        if explain
          # For structured output with explanations
          schema = {
            type: "object",
            properties: {
              corrected: { type: "string" },
              changes: {
                type: "array",
                items: { type: "string" }
              }
            },
            required: [ "corrected", "changes" ]
          }
          response = Base.call_llm(prompt, model: model, schema: schema, **options)
          JSON.parse(clean_json_response(response))
        else
          Base.call_llm(prompt, model: model, **options)
        end
      end

      private

      def self.clean_json_response(response)
        # Remove markdown code block formatting if present
        cleaned = response.gsub(/^```json\n/, "").gsub(/\n```$/, "").strip

        # If still no JSON, try to extract JSON from mixed content
        if !cleaned.start_with?("{") && cleaned.include?("{")
          # Find JSON object in the response
          json_match = cleaned.match(/\{[^}]*\}/m)
          cleaned = json_match[0] if json_match
        end

        cleaned
      end

      def self.build_prompt(text, explain:, preserve_style:)
        style_instruction = preserve_style ?
          "Preserve the original tone, style, and level of formality." :
          ""

        if explain
          output_instruction = <<~OUTPUT
            Return a JSON object with:
            - "corrected": the corrected text
            - "changes": an array of changes made (e.g., "their → they're", "tommorow → tomorrow")
          OUTPUT
        else
          output_instruction = "Return only the corrected text with no explanation or additional commentary."
        end

        <<~PROMPT
          Fix grammar, spelling, punctuation, and word choice errors in the following text.
          #{style_instruction}

          #{output_instruction}

          Text:
          #{text}
        PROMPT
      end
    end
  end
end
