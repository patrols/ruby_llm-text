require "test_helper"

class RubyLLM::Text::SentimentTest < Minitest::Test
  def setup
    @positive_text = "I absolutely love this restaurant!"
    @negative_text = "This product is terrible and broken."
    @neutral_text = "The weather is okay today."
  end

  def test_returns_structured_sentiment_with_confidence_by_default
    sentiment_response = {
      "label" => "positive",
      "confidence" => 0.95
    }.to_json

    RubyLLM::Text::Base.stubs(:call_llm).returns(sentiment_response)

    result = RubyLLM::Text::Sentiment.call(@positive_text)
    assert_kind_of Hash, result
    assert_equal "positive", result["label"]
    assert_equal 0.95, result["confidence"]
    assert result["confidence"].is_a?(Float)
  end

  def test_returns_simple_string_when_simple_is_true
    RubyLLM::Text::Base.stubs(:call_llm).returns("positive")

    result = RubyLLM::Text::Sentiment.call(@positive_text, simple: true)
    assert_kind_of String, result
    assert_equal "positive", result
  end

  def test_uses_default_categories_when_none_specified
    prompt = RubyLLM::Text::Sentiment.send(:build_prompt, @positive_text, categories: RubyLLM::Text::Sentiment::DEFAULT_CATEGORIES, simple: false)
    assert_includes prompt, "positive, negative, neutral"
  end

  def test_uses_custom_categories_when_specified
    custom_categories = ["happy", "sad", "angry"]
    prompt = RubyLLM::Text::Sentiment.send(:build_prompt, @positive_text, categories: custom_categories, simple: false)
    assert_includes prompt, "happy, sad, angry"
    refute_includes prompt, "positive"
  end

  def test_includes_json_instruction_when_not_simple
    prompt = RubyLLM::Text::Sentiment.send(:build_prompt, @positive_text, categories: ["positive", "negative"], simple: false)
    assert_includes prompt, "JSON object"
    assert_includes prompt, "label"
    assert_includes prompt, "confidence"
  end

  def test_requests_simple_output_when_simple_is_true
    prompt = RubyLLM::Text::Sentiment.send(:build_prompt, @positive_text, categories: ["positive", "negative"], simple: true)
    assert_includes prompt, "Return only the sentiment category name"
    refute_includes prompt, "JSON"
  end

  def test_uses_configured_model_when_specified
    RubyLLM::Text.configure do |config|
      config.sentiment_model = "claude-haiku-4-5"
    end

    RubyLLM::Text::Base.expects(:call_llm).with(anything, model: "claude-haiku-4-5").returns("positive")

    RubyLLM::Text::Sentiment.call(@positive_text, simple: true)
  end

  def test_passes_schema_when_not_simple
    sentiment_response = {
      "label" => "positive",
      "confidence" => 0.95
    }.to_json

    # Verify it gets called with a schema parameter
    RubyLLM::Text::Base.expects(:call_llm).with { |prompt, options|
      options.key?(:schema) && options[:schema][:type] == "object" &&
      options[:schema][:properties].key?(:label) && options[:schema][:properties].key?(:confidence)
    }.returns(sentiment_response)

    RubyLLM::Text::Sentiment.call(@positive_text)
  end

  def test_converts_confidence_to_float
    # Test with integer confidence
    sentiment_response = {
      "label" => "positive",
      "confidence" => 1  # integer
    }.to_json

    RubyLLM::Text::Base.stubs(:call_llm).returns(sentiment_response)

    result = RubyLLM::Text::Sentiment.call(@positive_text)
    assert_equal 1.0, result["confidence"]
    assert result["confidence"].is_a?(Float)
  end

  def test_handles_different_sentiment_categories
    categories = ["excited", "calm", "frustrated"]
    prompt = RubyLLM::Text::Sentiment.send(:build_prompt, @positive_text, categories: categories, simple: false)

    categories.each do |category|
      assert_includes prompt, category
    end
  end
end