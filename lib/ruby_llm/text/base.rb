module RubyLLM
  module Text
    module Base
      def self.call_llm(prompt, model: nil, temperature: nil, schema: nil, **options)
        model ||= RubyLLM.config.default_model
        temperature ||= RubyLLM::Text.config.temperature

        chat = RubyLLM.chat(model: model)
        chat = chat.with_temperature(temperature)
        if schema
          # Convert plain Hash schemas to RubyLLM::Schema objects if needed
          schema_obj = build_schema(schema)
          chat = chat.with_schema(schema_obj)
        end

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

      def self.build_schema(schema)
        # If already a schema object, return as-is
        return schema if schema.respond_to?(:schema)

        return nil unless schema.is_a?(Hash)

        schema_class = Class.new(RubyLLM::Schema)

        # Handle JSON Schema-style hashes (e.g., {type: "object", properties: {...}})
        if schema[:type] == "object" && schema[:properties]
          schema[:properties].each do |field, spec|
            # Handle oneOf union types - default to string for compatibility
            if spec[:oneOf]
              schema_class.string field # Use string as most flexible type
            else
              case spec[:type] || spec["type"]
              when "string"
                schema_class.string field
              when "number", "integer"
                schema_class.number field
              when "boolean"
                schema_class.boolean field
              when "array"
                # Handle array with items specification
                items_spec = spec[:items] || spec["items"]
                if items_spec
                  items_type = items_spec[:type] || items_spec["type"]
                  case items_type
                  when "string"
                    schema_class.array field, :string
                  when "number", "integer"
                    schema_class.array field, :number
                  when "boolean"
                    schema_class.array field, :boolean
                  else
                    schema_class.array field, :string
                  end
                else
                  schema_class.array field, :string
                end
              else
                schema_class.string field # fallback to string
              end
            end
          end
        else
          # Handle simple symbol-based schemas (e.g., {name: :string, age: :integer})
          schema.each do |field, type|
            case type
            when :string
              schema_class.string field
            when :integer, :number
              schema_class.number field
            when :boolean
              schema_class.boolean field
            when :array
              schema_class.array field
            else
              schema_class.string field # fallback to string
            end
          end
        end

        schema_class
      end
    end

    class Error < StandardError; end
  end
end
