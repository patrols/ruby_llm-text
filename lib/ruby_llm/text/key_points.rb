module RubyLLM
  module Text
    module KeyPoints
      FORMATS = {
        bullets: "• ",
        numbers: "1. ",
        sentences: ""
      }.freeze

      def self.call(text, max_points: nil, format: :sentences, model: nil, **options)
        model ||= RubyLLM::Text.config.model_for(:key_points)

        prompt = build_prompt(text, max_points: max_points, format: format)
        response = Base.call_llm(prompt, model: model, **options)

        # Parse response into array of strings
        parse_response(response, format)
      end

      private

      def self.build_prompt(text, max_points:, format:)
        count_instruction = max_points ? " (maximum #{max_points} points)" : ""

        format_instruction = case format
        when :bullets
          "Format each point with a bullet (•) at the start."
        when :numbers
          "Format as a numbered list (1. 2. 3. etc.)."
        when :sentences
          "Format as complete sentences, one per line."
        else
          "Format as complete sentences, one per line."
        end

        <<~PROMPT
          Extract the key points from the following text#{count_instruction}.
          #{format_instruction}
          Return only the key points, no preamble or explanation.
          Each point should be on a separate line.

          Text:
          #{text}
        PROMPT
      end

      def self.parse_response(response, format)
        lines = response.strip.split("\n").map(&:strip).reject(&:empty?)

        # Clean up formatting markers if they exist
        lines.map do |line|
          case format
          when :bullets
            line.gsub(/^[•\*\-]\s*/, "")
          when :numbers
            line.gsub(/^\d+\.\s*/, "")
          else
            line
          end
        end
      end
    end
  end
end
