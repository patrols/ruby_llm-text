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
    end

    class Error < StandardError; end
  end
end
