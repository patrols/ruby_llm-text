require "test_helper"

class RubyLLM::Text::TranslateTest < Minitest::Test
  def setup
    @text = "Bonjour le monde"
  end

  def test_translates_text_to_specified_language
    RubyLLM::Text::Base.stubs(:call_llm).returns("Hello world")

    result = RubyLLM::Text::Translate.call(@text, to: "en")
    assert_kind_of String, result
    assert_includes result.downcase, "hello"
  end

  def test_includes_source_language_when_specified
    prompt = RubyLLM::Text::Translate.send(:build_prompt, @text, to: "en", from: "fr")
    assert_includes prompt, "from fr to en"
  end

  def test_omits_source_language_when_not_specified
    prompt = RubyLLM::Text::Translate.send(:build_prompt, @text, to: "en", from: nil)
    assert_includes prompt, "to en"
    refute_includes prompt, "from"
  end

  def test_uses_configured_model_when_specified
    RubyLLM::Text.configure do |config|
      config.translate_model = "gpt-4.1-mini"
    end

    # Mock the Base.call_llm method
    RubyLLM::Text::Base.expects(:call_llm).with(anything, model: "gpt-4.1-mini").returns("Hello world")

    RubyLLM::Text::Translate.call(@text, to: "en")
  end
end
