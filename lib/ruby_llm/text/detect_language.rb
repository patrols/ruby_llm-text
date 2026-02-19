module RubyLLM
  module Text
    module DetectLanguage
      def self.call(text, include_confidence: false, model: nil, **options)
        Validation.validate_text!(text)
        model ||= RubyLLM::Text.config.model_for(:detect_language)

        prompt = build_prompt(text, include_confidence: include_confidence)

        if include_confidence
          # For structured output with confidence score and language code
          schema = build_confidence_schema()
          response = Base.call_llm(prompt, model: model, schema: schema, **options)

          begin
            result = JSON.parse(Base.clean_json_response(response))
          rescue JSON::ParserError
            # Fallback: if JSON parsing fails, return best-effort structured response
            cleaned_response = Base.clean_json_response(response)
            result = {
              "language" => cleaned_response,
              "confidence" => nil,
              "code" => nil
            }
          end

          # Convert confidence to float when present (preserve nil as "unknown")
          if result.key?("confidence") && !result["confidence"].nil?
            result["confidence"] = result["confidence"].to_f
          end

          result
        else
          Base.call_llm(prompt, model: model, **options)
        end
      end

      private

      def self.build_prompt(text, include_confidence:)
        if include_confidence
          output_instruction = <<~OUTPUT
            Return a JSON object with:
            - "language": the full language name (e.g., "English", "French", "Spanish")
            - "confidence": a confidence score between 0 and 1
            - "code": the ISO 639-1 language code (e.g., "en", "fr", "es")

            If the language cannot be reliably detected, return "unknown" as the language with low confidence.
          OUTPUT
        else
          output_instruction = <<~OUTPUT
            Return only the full language name (e.g., "English", "French", "Spanish").
            If the language cannot be reliably detected, return "unknown".
          OUTPUT
        end

        <<~PROMPT
          Detect the language of the following text.

          #{output_instruction}

          Text:
          #{text}
        PROMPT
      end

      def self.build_confidence_schema
        {
          type: "object",
          properties: {
            language: { type: "string" },
            confidence: { type: "number", minimum: 0, maximum: 1 },
            code: { type: "string" }
          },
          required: [ "language", "confidence", "code" ]
        }
      end
    end
  end
end
