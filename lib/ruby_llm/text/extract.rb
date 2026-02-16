require "ruby_llm/schema"

module RubyLLM
  module Text
    module Extract
      def self.call(text, schema: nil, model: nil, **options)
        model ||= RubyLLM::Text.config.model_for(:extract)
        raise ArgumentError, "schema is required for extraction" unless schema

        # Convert simple hash schema to RubyLLM::Schema
        schema_obj = build_schema(schema)
        prompt = build_prompt(text, schema)

        Base.call_llm(prompt, model: model, schema: schema_obj, **options)
      end

      private

      def self.build_schema(schema)
        # If already a schema object, return as-is
        return schema if schema.respond_to?(:schema)

        # Build dynamic schema class from hash
        schema_class = Class.new(RubyLLM::Schema)
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
        schema_class
      end

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
