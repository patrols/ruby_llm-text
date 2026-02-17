module RubyLLM
  module Text
    module Base
      def self.call_llm(prompt, model: nil, temperature: nil, schema: nil, **options)
        model ||= RubyLLM.config.default_model
        temperature ||= RubyLLM::Text.config.temperature

        chat = RubyLLM.chat(model: model)
        chat = chat.with_temperature(temperature)
        chat = chat.with_schema(schema) if schema

        # Apply any additional options
        options.each do |key, value|
          method_name = "with_#{key}"
          chat = chat.send(method_name, value) if chat.respond_to?(method_name)
        end

        response = chat.ask(prompt)
        response.content
      rescue => e
        raise RubyLLM::Text::Error, "LLM call failed: #{e.message}"
      end

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
    end

    class Error < StandardError; end
  end
end
