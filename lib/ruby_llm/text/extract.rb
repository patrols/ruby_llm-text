module RubyLLM
  module Text
    module Extract
      def self.call(text, schema: nil, model: nil, **options)
        Validation.validate_text!(text)
        Validation.validate_required!(schema, "schema")
        model ||= RubyLLM::Text.config.model_for(:extract)

        prompt = build_prompt(text, schema)

        Base.call_llm(prompt, model: model, schema: schema, **options)
      end

      private

      def self.build_prompt(text, schema)
        # Support both simple field-hash schemas and JSON Schema-style hashes
        properties = schema[:properties] || schema["properties"] if schema.respond_to?(:[])
        field_keys = if properties.is_a?(Hash)
                       properties.keys
        else
                       schema.keys
        end
        fields = field_keys.join(", ")

        <<~PROMPT
          Extract the following information from the text: #{fields}
          Return the data as structured JSON matching the provided schema.

          Text:
          #{text}
        PROMPT
      end
    end
  end
end
