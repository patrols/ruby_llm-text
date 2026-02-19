module RubyLLM
  module Text
    module Anonymize
      # Default PII types to detect and anonymize
      DEFAULT_PII_TYPES = [ :names, :emails, :phones, :addresses ].freeze

      def self.call(text, pii_types: DEFAULT_PII_TYPES, replacement_style: :generic, include_mapping: false, model: nil, **options)
        Validation.validate_text!(text)
        model ||= RubyLLM::Text.config.model_for(:anonymize)

        # Handle :all shortcut for all PII types
        pii_types = DEFAULT_PII_TYPES if pii_types == [ :all ]

        prompt = build_prompt(text, pii_types: pii_types, replacement_style: replacement_style, include_mapping: include_mapping)

        if include_mapping
          # For structured output with anonymized text and replacement mapping
          schema = build_mapping_schema()
          response = Base.call_llm(prompt, model: model, schema: schema, **options)

          begin
            result = JSON.parse(Base.clean_json_response(response))
          rescue JSON::ParserError
            # Fallback: if JSON parsing fails, return best-effort structured response
            cleaned_response = Base.clean_json_response(response)
            result = {
              "text" => cleaned_response,
              "mapping" => {}
            }
          end

          result
        else
          Base.call_llm(prompt, model: model, **options)
        end
      end

      private

      def self.build_prompt(text, pii_types:, replacement_style:, include_mapping:)
        # Build PII type instructions
        pii_instructions = build_pii_instructions(pii_types)
        replacement_instructions = build_replacement_instructions(replacement_style, pii_types)

        if include_mapping
          output_instruction = <<~OUTPUT
            Return a JSON object with:
            - "text": the anonymized text with PII replaced
            - "mapping": an object mapping each replacement token to its original value

            Example:
            {
              "text": "Contact [PERSON_1] at [EMAIL_1]",
              "mapping": {
                "[PERSON_1]": "John Doe",
                "[EMAIL_1]": "john.doe@example.com"
              }
            }
          OUTPUT
        else
          output_instruction = <<~OUTPUT
            Return only the anonymized text with PII replaced by appropriate tokens.
            Do not include any explanation or notes.
          OUTPUT
        end

        <<~PROMPT
          Anonymize the following text by replacing personally identifiable information (PII) with replacement tokens.

          #{pii_instructions}
          #{replacement_instructions}

          #{output_instruction}

          Text:
          #{text}
        PROMPT
      end

      def self.build_pii_instructions(pii_types)
        # Handle :all shortcut
        pii_types = DEFAULT_PII_TYPES if pii_types == [ :all ]

        instructions = [ "Identify and replace the following types of PII:" ]

        if pii_types.include?(:names)
          instructions << "- Names (personal names, full names, first names, last names)"
        end

        if pii_types.include?(:emails)
          instructions << "- Email addresses"
        end

        if pii_types.include?(:phones)
          instructions << "- Phone numbers (including various formats)"
        end

        if pii_types.include?(:addresses)
          instructions << "- Physical addresses (street addresses, cities, postal codes)"
        end

        if pii_types.include?(:ssn)
          instructions << "- Social Security Numbers"
        end

        if pii_types.include?(:credit_cards)
          instructions << "- Credit card numbers"
        end

        instructions.join("\n")
      end

      def self.build_replacement_instructions(replacement_style, pii_types)
        # Handle :all shortcut
        pii_types = DEFAULT_PII_TYPES if pii_types == [ :all ]

        instructions = [ "Use #{replacement_style} replacement tokens:" ]

        case replacement_style
        when :generic
          if pii_types.include?(:names)
            instructions << "- Names: [PERSON], [PERSON_1], [PERSON_2], etc. for multiple people"
          end
          if pii_types.include?(:emails)
            instructions << "- Emails: [EMAIL], [EMAIL_1], [EMAIL_2], etc. for multiple emails"
          end
          if pii_types.include?(:phones)
            instructions << "- Phones: [PHONE], [PHONE_1], [PHONE_2], etc."
          end
          if pii_types.include?(:addresses)
            instructions << "- Addresses: [ADDRESS], [ADDRESS_1], [ADDRESS_2], etc."
          end
          if pii_types.include?(:ssn)
            instructions << "- SSN: [SSN], [SSN_1], [SSN_2], etc."
          end
          if pii_types.include?(:credit_cards)
            instructions << "- Credit Cards: [CREDIT_CARD], [CREDIT_CARD_1], etc."
          end
        when :numbered
          if pii_types.include?(:names)
            instructions << "- Names: [PERSON_1], [PERSON_2], etc."
          end
          if pii_types.include?(:emails)
            instructions << "- Emails: [EMAIL_1], [EMAIL_2], etc."
          end
          if pii_types.include?(:phones)
            instructions << "- Phones: [PHONE_1], [PHONE_2], etc."
          end
          if pii_types.include?(:addresses)
            instructions << "- Addresses: [ADDRESS_1], [ADDRESS_2], etc."
          end
        when :descriptive
          if pii_types.include?(:names)
            instructions << "- Names: [FIRST_NAME], [LAST_NAME], [FULL_NAME]"
          end
          if pii_types.include?(:emails)
            instructions << "- Emails: [EMAIL_ADDRESS]"
          end
          if pii_types.include?(:phones)
            instructions << "- Phones: [PHONE_NUMBER]"
          end
          if pii_types.include?(:addresses)
            instructions << "- Addresses: [STREET_ADDRESS], [CITY], [POSTAL_CODE]"
          end
        else
          return build_replacement_instructions(:generic, pii_types)
        end

        instructions.join("\n")
      end

      def self.build_mapping_schema
        {
          type: "object",
          properties: {
            text: { type: "string" },
            mapping: {
              type: "object",
              additionalProperties: { type: "string" }
            }
          },
          required: [ "text", "mapping" ]
        }
      end
    end
  end
end
