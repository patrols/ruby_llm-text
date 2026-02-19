module RubyLLM
  module Text
    module GenerateTags
      def self.call(text, max_tags: nil, style: :keywords, model: nil, **options)
        Validation.validate_text!(text)
        model ||= RubyLLM::Text.config.model_for(:generate_tags)

        prompt = build_prompt(text, max_tags: max_tags, style: style)
        response = Base.call_llm(prompt, model: model, **options)

        # Parse response into array of strings
        parse_response(response, style)
      end

      private

      def self.build_prompt(text, max_tags:, style:)
        count_instruction = max_tags ? " (maximum #{max_tags} tags)" : ""

        style_instruction = case style
        when :keywords
          "Generate relevant keywords and key phrases that capture the main topics and concepts."
        when :topics
          "Generate broader topic categories and subject areas covered in the content."
        when :hashtags
          "Generate hashtag-style tags suitable for social media (include the # symbol)."
        else
          "Generate relevant keywords and key phrases that capture the main topics and concepts."
        end

        format_instruction = case style
        when :hashtags
          "Format each tag as a hashtag (e.g., #ruby, #programming)."
        else
          "Return simple words or short phrases without special formatting."
        end

        <<~PROMPT
          Analyze the following text and generate relevant tags#{count_instruction}.
          #{style_instruction}
          #{format_instruction}

          Return only the tags, one per line, no preamble or explanation.
          Each tag should be on a separate line.

          Text:
          #{text}
        PROMPT
      end

      def self.parse_response(response, style)
        lines = response.strip.split("\n").map(&:strip).reject(&:empty?)

        # Clean up formatting markers and normalize tags
        lines.map do |line|
          # Remove common formatting markers
          cleaned = line.gsub(/^[•\*\-]\s*/, "")  # Remove bullets
          cleaned = cleaned.gsub(/^\d+\.\s*/, "")  # Remove numbers
          cleaned = cleaned.gsub(/^["']/, "").gsub(/["']$/, "")  # Remove quotes more explicitly

          # Handle comma-separated tags on single line (some LLMs do this)
          if cleaned.include?(",") && !cleaned.start_with?("#")
            cleaned.split(",").map(&:strip).map { |tag| tag.gsub(/^["']/, "").gsub(/["']$/, "") }
          else
            cleaned
          end
        end.flatten.reject(&:empty?).uniq
      end
    end
  end
end
