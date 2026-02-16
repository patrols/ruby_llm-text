require "test_helper"
require "ruby_llm/text/string_ext"

class StringExtensionsTest < Minitest::Test
  def setup
    @text = "This is test text for utility methods."
  end

  def test_summarize_delegates_to_text_summarize
    RubyLLM::Text.expects(:summarize).with(@text, length: :short).returns("summary")

    result = @text.summarize(length: :short)
    assert_equal "summary", result
  end

  def test_translate_delegates_to_text_translate
    RubyLLM::Text.expects(:translate).with(@text, to: "es").returns("translation")

    result = @text.translate(to: "es")
    assert_equal "translation", result
  end

  def test_extract_delegates_to_text_extract
    RubyLLM::Text.expects(:extract).with(@text, schema: { key: :string }).returns("data")

    result = @text.extract(schema: { key: :string })
    assert_equal "data", result
  end

  def test_classify_delegates_to_text_classify
    RubyLLM::Text.expects(:classify).with(@text, categories: [ "positive", "negative" ]).returns("positive")

    result = @text.classify(categories: [ "positive", "negative" ])
    assert_equal "positive", result
  end
end
