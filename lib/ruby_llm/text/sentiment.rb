module RubyLLM
  module Text
    module Sentiment
      DEFAULT_CATEGORIES = [ "positive", "negative", "neutral" ].freeze

      def self.call(text, categories: DEFAULT_CATEGORIES, simple: false, model: nil, **options)
        model ||= RubyLLM::Text.config.model_for(:sentiment)

        prompt = build_prompt(text, categories: categories, simple: simple)

        if simple
          Base.call_llm(prompt, model: model, **options)
        else
          # For structured output with confidence score
          schema = {
            type: "object",
            properties: {
              label: { type: "string", enum: categories },
              confidence: { type: "number", minimum: 0, maximum: 1 }
            },
            required: [ "label", "confidence" ]
          }
          response = Base.call_llm(prompt, model: model, schema: schema, **options)

          begin
            result = JSON.parse(clean_json_response(response))
            # Ensure confidence is a float
            result["confidence"] = result["confidence"].to_f
            result
          rescue JSON::ParserError
            # Fallback: if JSON parsing fails, try simple mode
            simple_prompt = build_prompt(text, categories: categories, simple: true)
            simple_response = Base.call_llm(simple_prompt, model: model, **options)
            { "label" => simple_response.strip, "confidence" => 0.7 }
          end
        end
      end

      private

      def self.clean_json_response(response)
        # Remove markdown code block formatting if present
        cleaned = response.gsub(/^```json\n/, "").gsub(/\n```$/, "").strip

        # If still no JSON, try to extract JSON from mixed content
        if !cleaned.start_with?("{") && cleaned.include?("{")
          # Find JSON object in the response with proper brace matching
          brace_count = 0
          start_pos = cleaned.index("{")
          if start_pos
            end_pos = start_pos
            cleaned[start_pos..-1].each_char.with_index(start_pos) do |char, i|
              if char == "{"
                brace_count += 1
              elsif char == "}"
                brace_count -= 1
                if brace_count == 0
                  end_pos = i
                  break
                end
              end
            end

            if brace_count == 0
              cleaned = cleaned[start_pos..end_pos]
            end
          end
        end

        cleaned
      end

      def self.build_prompt(text, categories:, simple:)
        categories_list = categories.join(", ")

        if simple
          output_instruction = "Return only the sentiment category name, nothing else."
        else
          output_instruction = <<~OUTPUT
            Return a JSON object with:
            - "label": the sentiment category
            - "confidence": a confidence score between 0 and 1 (where 1 is completely confident)
          OUTPUT
        end

        <<~PROMPT
          Analyze the sentiment of the following text.

          Categories: #{categories_list}

          #{output_instruction}

          Text:
          #{text}
        PROMPT
      end
    end
  end
end
