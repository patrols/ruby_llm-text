module RubyLLM
  module Text
    module Summarize
      LENGTHS = {
        short: "1-2 sentences",
        medium: "3-5 sentences",
        detailed: "1-2 paragraphs"
      }.freeze

      def self.call(text, length: :medium, max_words: nil, model: nil, **options)
        model ||= RubyLLM::Text.config.model_for(:summarize)

        prompt = build_prompt(text, length: length, max_words: max_words)
        Base.call_llm(prompt, model: model, **options)
      end

      private

      def self.build_prompt(text, length:, max_words:)
        length_instruction = LENGTHS[length] || length.to_s
        word_limit = max_words ? " (maximum #{max_words} words)" : ""

        <<~PROMPT
          Summarize the following text.
          Length: #{length_instruction}#{word_limit}
          Return only the summary, no preamble or explanation.

          Text:
          #{text}
        PROMPT
      end
    end
  end
end
