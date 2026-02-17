module RubyLLM
  module Text
    module Answer
      def self.call(text, question, include_confidence: false, model: nil, **options)
        model ||= RubyLLM::Text.config.model_for(:answer)

        prompt = build_prompt(text, question, include_confidence: include_confidence)

        if include_confidence
          # For structured output with confidence score
          schema = build_confidence_schema(question)
          response = Base.call_llm(prompt, model: model, schema: schema, **options)
          result = JSON.parse(response)

          # Convert confidence to float and handle boolean conversion
          if result.key?("confidence")
            result["confidence"] = result["confidence"].to_f
          end

          # Handle boolean answers
          if is_boolean_answer?(result["answer"])
            result["answer"] = parse_boolean(result["answer"])
          end

          result
        else
          response = Base.call_llm(prompt, model: model, **options)

          # Handle boolean answers for simple responses
          if is_boolean_question?(question)
            parse_boolean(response)
          else
            response
          end
        end
      end

      private

      def self.build_prompt(text, question, include_confidence:)
        if include_confidence
          output_instruction = <<~OUTPUT
            Return a JSON object with:
            - "answer": the answer to the question (use true/false for yes/no questions)
            - "confidence": a confidence score between 0 and 1

            If the answer cannot be found in the text, return "information not available" as the answer with low confidence.
          OUTPUT
        else
          output_instruction = <<~OUTPUT
            Answer the question based only on the information provided in the text.
            For yes/no questions, respond with true or false.
            If the answer cannot be found in the text, respond with "information not available".
            Return only the answer, no explanation.
          OUTPUT
        end

        <<~PROMPT
          Based on the following text, answer this question: "#{question}"

          #{output_instruction}

          Text:
          #{text}
        PROMPT
      end

      def self.build_confidence_schema(question)
        answer_type = if is_boolean_question?(question)
          { "type" => "boolean" }
        else
          { "type" => "string" }
        end

        {
          type: "object",
          properties: {
            answer: answer_type,
            confidence: { type: "number", minimum: 0, maximum: 1 }
          },
          required: [ "answer", "confidence" ]
        }
      end

      def self.is_boolean_question?(question)
        question_lower = question.downcase.strip
        question_lower.start_with?("is ", "are ", "was ", "were ", "do ", "does ", "did ", "can ", "could ", "will ", "would ", "should ") ||
        question_lower.start_with?("has ", "have ", "had ") ||
        question_lower.include?(" or not") ||
        question_lower.end_with?("?") && (question_lower.include?("yes") || question_lower.include?("no"))
      end

      def self.is_boolean_answer?(answer)
        return true if answer.is_a?(TrueClass) || answer.is_a?(FalseClass)
        return false unless answer.is_a?(String)

        answer_lower = answer.downcase.strip
        [ "true", "false", "yes", "no" ].include?(answer_lower)
      end

      def self.parse_boolean(answer)
        return answer if answer.is_a?(TrueClass) || answer.is_a?(FalseClass)
        return answer unless answer.is_a?(String)

        answer_lower = answer.downcase.strip
        case answer_lower
        when "true", "yes"
          true
        when "false", "no"
          false
        else
          answer # Return as-is if not clearly boolean
        end
      end
    end
  end
end
