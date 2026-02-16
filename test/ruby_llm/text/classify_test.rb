require "test_helper"

class RubyLLM::Text::ClassifyTest < Minitest::Test
  def setup
    @text = "This product is amazing! I love it so much."
    @categories = [ "positive", "negative", "neutral" ]
  end

  def test_classifies_text_into_provided_categories
    RubyLLM::Text::Base.stubs(:call_llm).returns("positive")

    result = RubyLLM::Text::Classify.call(@text, categories: @categories)
    assert_kind_of String, result
    assert_includes @categories, result.downcase
  end

  def test_raises_error_when_categories_are_empty
    error = assert_raises(ArgumentError) do
      RubyLLM::Text::Classify.call(@text, categories: [])
    end
    assert_equal "categories are required", error.message
  end

  def test_builds_correct_prompt_with_category_list
    prompt = RubyLLM::Text::Classify.send(:build_prompt, @text, @categories)
    assert_includes prompt, "- positive"
    assert_includes prompt, "- negative"
    assert_includes prompt, "- neutral"
  end

  def test_uses_configured_model_when_specified
    RubyLLM::Text.configure do |config|
      config.classify_model = "gpt-4.1-mini"
    end

    # Mock the Base.call_llm method
    RubyLLM::Text::Base.expects(:call_llm).with(anything, model: "gpt-4.1-mini").returns("positive")

    RubyLLM::Text::Classify.call(@text, categories: @categories)
  end
end
