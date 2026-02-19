module RubyLLM
  module Text
    module Classify
      def self.call(text, categories:, model: nil, **options)
        Validation.validate_text!(text)
        Validation.validate_array!(categories, "categories")
        model ||= RubyLLM::Text.config.model_for(:classify)

        prompt = build_prompt(text, categories)
        Base.call_llm(prompt, model: model, **options)
      end

      private

      def self.build_prompt(text, categories)
        category_list = categories.map { |c| "- #{c}" }.join("\n")

        <<~PROMPT
          Classify the following text into one of these categories:
          #{category_list}

          Return only the category name, nothing else.

          Text:
          #{text}
        PROMPT
      end
    end
  end
end
