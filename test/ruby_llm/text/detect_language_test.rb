require "test_helper"

class RubyLLM::Text::DetectLanguageTest < Minitest::Test
  def setup
    @english_text = "Hello, how are you doing today?"
    @french_text = "Bonjour, comment allez-vous aujourd'hui?"
    @multilingual_text = "Hello world. Bonjour le monde."
  end

  def test_detects_language_with_simple_response
    RubyLLM::Text::Base.stubs(:call_llm).returns("English")

    result = RubyLLM::Text::DetectLanguage.call(@english_text)

    assert_kind_of String, result
    assert_equal "English", result
  end

  def test_detects_language_with_confidence_scoring
    confidence_response = {
      "language" => "French",
      "confidence" => 0.95,
      "code" => "fr"
    }.to_json

    RubyLLM::Text::Base.stubs(:call_llm).returns(confidence_response)

    result = RubyLLM::Text::DetectLanguage.call(@french_text, include_confidence: true)

    assert_kind_of Hash, result
    assert_equal "French", result["language"]
    assert_equal 0.95, result["confidence"]
    assert_equal "fr", result["code"]
    assert result["confidence"].is_a?(Float)
  end

  def test_handles_unknown_language
    RubyLLM::Text::Base.stubs(:call_llm).returns("unknown")

    result = RubyLLM::Text::DetectLanguage.call("xyz123!@#")

    assert_equal "unknown", result
  end

  def test_handles_json_parsing_failure_gracefully
    RubyLLM::Text::Base.stubs(:call_llm).returns("Invalid JSON response")

    result = RubyLLM::Text::DetectLanguage.call(@english_text, include_confidence: true)

    assert_kind_of Hash, result
    assert_equal "Invalid JSON response", result["language"]
    assert_nil result["confidence"]
    assert_nil result["code"]
  end

  def test_converts_confidence_to_float
    confidence_response = {
      "language" => "Spanish",
      "confidence" => 1,
      "code" => "es"
    }.to_json

    RubyLLM::Text::Base.stubs(:call_llm).returns(confidence_response)

    result = RubyLLM::Text::DetectLanguage.call(@english_text, include_confidence: true)

    assert_equal 1.0, result["confidence"]
    assert result["confidence"].is_a?(Float)
  end

  def test_builds_correct_prompt_for_simple_detection
    prompt = RubyLLM::Text::DetectLanguage.send(:build_prompt, @english_text, include_confidence: false)

    assert_includes prompt, "Detect the language"
    assert_includes prompt, @english_text
    assert_includes prompt, "Return only the full language name"
    refute_includes prompt, "JSON object"
  end

  def test_builds_correct_prompt_for_confidence_detection
    prompt = RubyLLM::Text::DetectLanguage.send(:build_prompt, @french_text, include_confidence: true)

    assert_includes prompt, "Detect the language"
    assert_includes prompt, @french_text
    assert_includes prompt, "Return a JSON object"
    assert_includes prompt, "confidence"
    assert_includes prompt, "code"
  end

  def test_passes_schema_when_include_confidence_true
    RubyLLM::Text::Base.expects(:call_llm).with { |prompt, options|
      options.key?(:schema) &&
      options[:schema][:type] == "object" &&
      options[:schema][:properties].key?(:language) &&
      options[:schema][:properties].key?(:confidence) &&
      options[:schema][:properties].key?(:code)
    }.returns('{"language": "English", "confidence": 0.9, "code": "en"}')

    RubyLLM::Text::DetectLanguage.call(@english_text, include_confidence: true)
  end

  def test_uses_configured_model_when_specified
    RubyLLM::Text.configure do |config|
      config.detect_language_model = "gpt-4o-mini"
    end

    RubyLLM::Text::Base.expects(:call_llm).with(anything, model: "gpt-4o-mini").returns("English")
    RubyLLM::Text::DetectLanguage.call(@english_text)
  end

  def test_module_level_api_delegates_correctly
    RubyLLM::Text::Base.stubs(:call_llm).returns("German")

    result = RubyLLM::Text.detect_language(@english_text)

    assert_equal "German", result
  end
end
