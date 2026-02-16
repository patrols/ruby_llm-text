require "test_helper"

class RubyLLM::Text::SummarizeTest < Minitest::Test
  def setup
    @text = "This is a long article that needs to be summarized. It contains many important points and details that should be condensed into a shorter form."
  end

  def test_summarizes_text_with_default_options
    RubyLLM::Text::Base.stubs(:call_llm).returns("A brief summary.")

    result = RubyLLM::Text::Summarize.call(@text)
    assert_kind_of String, result
    assert result.length < @text.length
  end

  def test_respects_length_parameter
    prompt = RubyLLM::Text::Summarize.send(:build_prompt, @text, length: :short, max_words: nil)
    assert_includes prompt, "1-2 sentences"
  end

  def test_respects_max_words_parameter
    prompt = RubyLLM::Text::Summarize.send(:build_prompt, @text, length: :medium, max_words: 50)
    assert_includes prompt, "maximum 50 words"
  end

  def test_uses_configured_model_when_specified
    RubyLLM::Text.configure do |config|
      config.summarize_model = "gpt-4.1-mini"
    end

    # Mock the Base.call_llm method
    RubyLLM::Text::Base.expects(:call_llm).with(anything, model: "gpt-4.1-mini").returns("Summary")

    RubyLLM::Text::Summarize.call(@text)
  end

  def test_handles_custom_length_strings
    prompt = RubyLLM::Text::Summarize.send(:build_prompt, @text, length: "very brief", max_words: nil)
    assert_includes prompt, "very brief"
  end
end
