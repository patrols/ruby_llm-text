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

  def test_fix_grammar_delegates_to_text_fix_grammar
    RubyLLM::Text.expects(:fix_grammar).with(@text, preserve_style: true).returns("corrected text")

    result = @text.fix_grammar(preserve_style: true)
    assert_equal "corrected text", result
  end

  def test_sentiment_delegates_to_text_sentiment
    RubyLLM::Text.expects(:sentiment).with(@text, simple: true).returns("positive")

    result = @text.sentiment(simple: true)
    assert_equal "positive", result
  end

  def test_key_points_delegates_to_text_key_points
    RubyLLM::Text.expects(:key_points).with(@text, max_points: 3).returns([ "Point 1", "Point 2", "Point 3" ])

    result = @text.key_points(max_points: 3)
    assert_equal [ "Point 1", "Point 2", "Point 3" ], result
  end

  def test_rewrite_delegates_to_text_rewrite
    RubyLLM::Text.expects(:rewrite).with(@text, tone: :professional).returns("professional text")

    result = @text.rewrite(tone: :professional)
    assert_equal "professional text", result
  end

  def test_answer_delegates_to_text_answer
    question = "What is the main topic?"
    RubyLLM::Text.expects(:answer).with(@text, question, include_confidence: true).returns({ "answer" => "testing", "confidence" => 0.9 })

    result = @text.answer(question, include_confidence: true)
    assert_equal({ "answer" => "testing", "confidence" => 0.9 }, result)
  end
end
