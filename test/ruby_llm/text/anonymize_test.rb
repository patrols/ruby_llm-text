require "test_helper"

class RubyLLM::Text::AnonymizeTest < Minitest::Test
  def setup
    @pii_text = "Contact John Doe at john.doe@example.com or call him at (555) 123-4567. His address is 123 Main St, Anytown, CA 90210."
    @simple_text = "Hello world, this is a test message."
    @email_only = "Please email support at help@company.com for assistance."
  end

  def test_anonymizes_text_with_simple_response
    anonymized = "Contact [PERSON] at [EMAIL] or call him at [PHONE]. His address is [ADDRESS]."
    RubyLLM::Text::Base.stubs(:call_llm).returns(anonymized)

    result = RubyLLM::Text::Anonymize.call(@pii_text)

    assert_kind_of String, result
    assert_equal anonymized, result
  end

  def test_returns_structured_response_with_mapping
    mapping_response = {
      "text" => "Contact [PERSON_1] at [EMAIL_1] or call him at [PHONE_1]. His address is [ADDRESS_1].",
      "mapping" => {
        "[PERSON_1]" => "John Doe",
        "[EMAIL_1]" => "john.doe@example.com",
        "[PHONE_1]" => "(555) 123-4567",
        "[ADDRESS_1]" => "123 Main St, Anytown, CA 90210"
      }
    }.to_json

    RubyLLM::Text::Base.stubs(:call_llm).returns(mapping_response)

    result = RubyLLM::Text::Anonymize.call(@pii_text, include_mapping: true)

    assert_kind_of Hash, result
    assert result.key?("text")
    assert result.key?("mapping")
    assert_includes result["text"], "[PERSON_1]"
    assert_equal "John Doe", result["mapping"]["[PERSON_1]"]
  end

  def test_handles_json_parsing_failure_gracefully
    RubyLLM::Text::Base.stubs(:call_llm).returns("Invalid JSON response")

    result = RubyLLM::Text::Anonymize.call(@pii_text, include_mapping: true)

    assert_kind_of Hash, result
    assert_equal "Invalid JSON response", result["text"]
    assert_equal({}, result["mapping"])
  end

  def test_handles_all_pii_types_shortcut
    prompt = RubyLLM::Text::Anonymize.send(:build_prompt, @pii_text,
                                           pii_types: [ :all ],
                                           replacement_style: :generic,
                                           include_mapping: false)

    assert_includes prompt, "Names"
    assert_includes prompt, "Email addresses"
    assert_includes prompt, "Phone numbers"
    assert_includes prompt, "Physical addresses"
  end

  def test_handles_selective_pii_types
    prompt = RubyLLM::Text::Anonymize.send(:build_prompt, @email_only,
                                           pii_types: [ :emails ],
                                           replacement_style: :generic,
                                           include_mapping: false)

    assert_includes prompt, "Email addresses"
    refute_includes prompt, "Names"
    refute_includes prompt, "Phone numbers"
  end

  def test_builds_generic_replacement_instructions
    prompt = RubyLLM::Text::Anonymize.send(:build_prompt, @pii_text,
                                           pii_types: [ :names, :emails ],
                                           replacement_style: :generic,
                                           include_mapping: false)

    assert_includes prompt, "[PERSON]"
    assert_includes prompt, "[EMAIL]"
    assert_includes prompt, "[PERSON_1], [PERSON_2]"
  end

  def test_builds_numbered_replacement_instructions
    prompt = RubyLLM::Text::Anonymize.send(:build_prompt, @pii_text,
                                           pii_types: [ :names ],
                                           replacement_style: :numbered,
                                           include_mapping: false)

    assert_includes prompt, "[PERSON_1], [PERSON_2]"
    refute_includes prompt, "[PERSON], [PERSON_1]"
  end

  def test_builds_descriptive_replacement_instructions
    prompt = RubyLLM::Text::Anonymize.send(:build_prompt, @pii_text,
                                           pii_types: [ :names, :emails ],
                                           replacement_style: :descriptive,
                                           include_mapping: false)

    assert_includes prompt, "[FIRST_NAME]"
    assert_includes prompt, "[EMAIL_ADDRESS]"
  end

  def test_builds_simple_output_instruction
    prompt = RubyLLM::Text::Anonymize.send(:build_prompt, @pii_text,
                                           pii_types: [ :names ],
                                           replacement_style: :generic,
                                           include_mapping: false)

    assert_includes prompt, "Return only the anonymized text"
    refute_includes prompt, "JSON object"
  end

  def test_builds_mapping_output_instruction
    prompt = RubyLLM::Text::Anonymize.send(:build_prompt, @pii_text,
                                           pii_types: [ :names ],
                                           replacement_style: :generic,
                                           include_mapping: true)

    assert_includes prompt, "Return a JSON object"
    assert_includes prompt, "mapping"
    assert_includes prompt, "original value"
  end

  def test_passes_schema_when_include_mapping_true
    RubyLLM::Text::Base.expects(:call_llm).with { |prompt, options|
      options.key?(:schema) &&
      options[:schema][:type] == "object" &&
      options[:schema][:properties].key?(:text) &&
      options[:schema][:properties].key?(:mapping)
    }.returns('{"text": "anonymized", "mapping": {}}')

    RubyLLM::Text::Anonymize.call(@pii_text, include_mapping: true)
  end

  def test_supports_additional_pii_types
    prompt = RubyLLM::Text::Anonymize.send(:build_prompt, "SSN: 123-45-6789, Card: 4111111111111111",
                                           pii_types: [ :ssn, :credit_cards ],
                                           replacement_style: :generic,
                                           include_mapping: false)

    assert_includes prompt, "Social Security Numbers"
    assert_includes prompt, "Credit card numbers"
  end

  def test_fallback_to_generic_for_unknown_replacement_style
    prompt = RubyLLM::Text::Anonymize.send(:build_prompt, @pii_text,
                                           pii_types: [ :names ],
                                           replacement_style: :unknown,
                                           include_mapping: false)

    assert_includes prompt, "[PERSON]"
    assert_includes prompt, "[PERSON_1], [PERSON_2]"
  end

  def test_uses_configured_model_when_specified
    RubyLLM::Text.configure do |config|
      config.anonymize_model = "claude-3-5-sonnet"
    end

    RubyLLM::Text::Base.expects(:call_llm).with(anything, model: "claude-3-5-sonnet").returns("[PERSON]")
    RubyLLM::Text::Anonymize.call(@pii_text)
  end

  def test_module_level_api_delegates_correctly
    RubyLLM::Text::Base.stubs(:call_llm).returns("Anonymized text")

    result = RubyLLM::Text.anonymize(@pii_text, pii_types: [ :emails ])

    assert_equal "Anonymized text", result
  end
end
