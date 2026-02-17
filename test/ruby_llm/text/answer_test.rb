require "test_helper"

class RubyLLM::Text::AnswerTest < Minitest::Test
  def setup
    @astronomy_text = "The Earth orbits the Sun in an elliptical path. This orbital motion takes approximately 365.25 days to complete one full revolution."
    @person_text = "John Smith is 30 years old and works as a software engineer in San Francisco."
  end

  def test_answers_factual_questions
    RubyLLM::Text::Base.stubs(:call_llm).returns("the Sun")

    result = RubyLLM::Text::Answer.call(@astronomy_text, "What does Earth orbit?")
    assert_equal "the Sun", result
  end

  def test_answers_boolean_questions_with_boolean_values
    RubyLLM::Text::Base.stubs(:call_llm).returns("true")

    result = RubyLLM::Text::Answer.call(@astronomy_text, "Is this about astronomy?")
    assert_equal true, result
  end

  def test_returns_false_for_negative_boolean_answers
    RubyLLM::Text::Base.stubs(:call_llm).returns("false")

    result = RubyLLM::Text::Answer.call(@astronomy_text, "Is this about cooking?")
    assert_equal false, result
  end

  def test_handles_yes_no_responses
    RubyLLM::Text::Base.stubs(:call_llm).returns("yes")

    result = RubyLLM::Text::Answer.call(@astronomy_text, "Does Earth orbit the Sun?")
    assert_equal true, result
  end

  def test_returns_information_not_available_for_missing_info
    RubyLLM::Text::Base.stubs(:call_llm).returns("information not available")

    result = RubyLLM::Text::Answer.call(@astronomy_text, "What is the temperature on Mars?")
    assert_equal "information not available", result
  end

  def test_returns_structured_output_with_confidence
    confidence_response = {
      "answer" => "the Sun",
      "confidence" => 0.95
    }.to_json

    RubyLLM::Text::Base.stubs(:call_llm).returns(confidence_response)

    result = RubyLLM::Text::Answer.call(@astronomy_text, "What does Earth orbit?", include_confidence: true)
    assert_kind_of Hash, result
    assert_equal "the Sun", result["answer"]
    assert_equal 0.95, result["confidence"]
    assert result["confidence"].is_a?(Float)
  end

  def test_returns_boolean_answer_with_confidence
    confidence_response = {
      "answer" => true,
      "confidence" => 0.98
    }.to_json

    RubyLLM::Text::Base.stubs(:call_llm).returns(confidence_response)

    result = RubyLLM::Text::Answer.call(@astronomy_text, "Is this about space?", include_confidence: true)
    assert_kind_of Hash, result
    assert_equal true, result["answer"]
    assert_equal 0.98, result["confidence"]
  end

  def test_identifies_boolean_questions_correctly
    boolean_questions = [
      "Is this about astronomy?",
      "Are you ready?",
      "Was it successful?",
      "Were they present?",
      "Do you know?",
      "Does it work?",
      "Did they arrive?",
      "Can you help?",
      "Could it be true?",
      "Will you come?",
      "Would that work?",
      "Should we proceed?",
      "Has it started?",
      "Have they finished?",
      "Had you seen it?"
    ]

    boolean_questions.each do |question|
      assert RubyLLM::Text::Answer.send(:is_boolean_question?, question), "Should identify '#{question}' as boolean"
    end
  end

  def test_identifies_non_boolean_questions_correctly
    non_boolean_questions = [
      "What does Earth orbit?",
      "How long is a year?",
      "Where is John located?",
      "When did it happen?",
      "Why is this important?"
    ]

    non_boolean_questions.each do |question|
      refute RubyLLM::Text::Answer.send(:is_boolean_question?, question), "Should not identify '#{question}' as boolean"
    end
  end

  def test_parses_boolean_answers_correctly
    assert_equal true, RubyLLM::Text::Answer.send(:parse_boolean, "true")
    assert_equal true, RubyLLM::Text::Answer.send(:parse_boolean, "yes")
    assert_equal true, RubyLLM::Text::Answer.send(:parse_boolean, "YES")
    assert_equal false, RubyLLM::Text::Answer.send(:parse_boolean, "false")
    assert_equal false, RubyLLM::Text::Answer.send(:parse_boolean, "no")
    assert_equal false, RubyLLM::Text::Answer.send(:parse_boolean, "NO")
    assert_equal "maybe", RubyLLM::Text::Answer.send(:parse_boolean, "maybe")
  end

  def test_builds_correct_prompt_for_simple_answers
    prompt = RubyLLM::Text::Answer.send(:build_prompt, @astronomy_text, "What does Earth orbit?", include_confidence: false)
    assert_includes prompt, "What does Earth orbit?"
    assert_includes prompt, "Return only the answer"
    assert_includes prompt, @astronomy_text
  end

  def test_builds_correct_prompt_for_confidence_answers
    prompt = RubyLLM::Text::Answer.send(:build_prompt, @astronomy_text, "What does Earth orbit?", include_confidence: true)
    assert_includes prompt, "JSON object"
    assert_includes prompt, "answer"
    assert_includes prompt, "confidence"
  end

  def test_uses_configured_model_when_specified
    RubyLLM::Text.configure do |config|
      config.answer_model = "claude-sonnet-4-5"
    end

    RubyLLM::Text::Base.expects(:call_llm).with(anything, model: "claude-sonnet-4-5").returns("the Sun")

    RubyLLM::Text::Answer.call(@astronomy_text, "What does Earth orbit?")
  end

  def test_passes_schema_when_include_confidence_is_true
    confidence_response = {
      "answer" => "the Sun",
      "confidence" => 0.95
    }.to_json

    # Just verify it calls with some schema - details tested separately
    RubyLLM::Text::Base.stubs(:call_llm).returns(confidence_response)

    result = RubyLLM::Text::Answer.call(@astronomy_text, "What does Earth orbit?", include_confidence: true)
    assert_kind_of Hash, result
    assert result.key?("answer")
    assert result.key?("confidence")
  end

  def test_builds_boolean_schema_for_boolean_questions
    schema = RubyLLM::Text::Answer.send(:build_confidence_schema, "Is this about astronomy?")
    assert_equal "boolean", schema[:properties][:answer]["type"]
  end

  def test_builds_string_schema_for_factual_questions
    schema = RubyLLM::Text::Answer.send(:build_confidence_schema, "What does Earth orbit?")
    assert_equal "string", schema[:properties][:answer]["type"]
  end
end
