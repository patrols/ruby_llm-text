module RubyLLM
  module Text
    module Translate
      def self.call(text, to:, from: nil, model: nil, **options)
        Validation.validate_text!(text)
        Validation.validate_required!(to, "to")
        model ||= RubyLLM::Text.config.model_for(:translate)

        prompt = build_prompt(text, to: to, from: from)
        Base.call_llm(prompt, model: model, **options)
      end

      private

      def self.build_prompt(text, to:, from:)
        from_instruction = from ? "from #{from} " : ""

        <<~PROMPT
          Translate the following text #{from_instruction}to #{to}.
          Return only the translated text, no explanation or notes.

          Text:
          #{text}
        PROMPT
      end
    end
  end
end
