module RubyLLM
  module Text
    module Rewrite
      TONES = {
        casual: "friendly, informal, and conversational",
        professional: "business-appropriate, formal, and polished",
        academic: "scholarly, formal, and precise",
        creative: "engaging, descriptive, and imaginative",
        concise: "brief, direct, and to-the-point"
      }.freeze

      STYLES = {
        concise: "Make it shorter and more direct while preserving meaning",
        detailed: "Expand with more context, examples, and explanation",
        formal: "Use formal language and professional terminology",
        casual: "Use informal, friendly language"
      }.freeze

      def self.call(text, tone: nil, style: nil, instruction: nil, model: nil, **options)
        model ||= RubyLLM::Text.config.model_for(:rewrite)

        # Validate that at least one transformation is specified
        if tone.nil? && style.nil? && instruction.nil?
          raise ArgumentError, "Must specify at least one of: tone, style, or instruction"
        end

        prompt = build_prompt(text, tone: tone, style: style, instruction: instruction)
        Base.call_llm(prompt, model: model, **options)
      end

      private

      def self.build_prompt(text, tone:, style:, instruction:)
        transformations = []

        if tone
          tone_description = TONES[tone] || tone.to_s
          transformations << "Tone: #{tone_description}"
        end

        if style
          style_description = STYLES[style] || style.to_s
          transformations << "Style: #{style_description}"
        end

        if instruction
          transformations << "Additional instruction: #{instruction}"
        end

        transformation_text = transformations.join("\n")

        <<~PROMPT
          Rewrite the following text according to these requirements:

          #{transformation_text}

          Return only the rewritten text, no explanation or commentary.

          Text:
          #{text}
        PROMPT
      end
    end
  end
end
