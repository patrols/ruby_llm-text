module RubyLLM
  module Text
    module Extract
      def self.call(text, schema: nil, model: nil, **options)
        model ||= RubyLLM::Text.config.model_for(:extract)
        raise ArgumentError, "schema is required for extraction" unless schema

        prompt = build_prompt(text, schema)

        Base.call_llm(prompt, model: model, schema: schema, **options)
      end

      private

      def self.build_prompt(text, schema)
        fields = schema.keys.join(", ")

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
