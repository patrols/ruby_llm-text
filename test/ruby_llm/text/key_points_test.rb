require "test_helper"

class RubyLLM::Text::KeyPointsTest < Minitest::Test
  def setup
    @long_text = "This is a meeting summary with many important points. First, we discussed the budget allocation for Q3. Second, we agreed to hire two new developers. Third, the marketing campaign will launch next month. Fourth, we need to update the website design. Finally, everyone should submit their timesheets by Friday."
  end

  def test_extracts_key_points_as_array
    response = "Budget allocation for Q3 discussed\nHiring two new developers agreed\nMarketing campaign launches next month"
    RubyLLM::Text::Base.stubs(:call_llm).returns(response)

    result = RubyLLM::Text::KeyPoints.call(@long_text)
    assert_kind_of Array, result
    assert_equal 3, result.length
    assert_includes result, "Budget allocation for Q3 discussed"
    assert_includes result, "Hiring two new developers agreed"
  end

  def test_respects_max_points_parameter
    prompt = RubyLLM::Text::KeyPoints.send(:build_prompt, @long_text, max_points: 3, format: :sentences)
    assert_includes prompt, "maximum 3 points"
  end

  def test_omits_max_points_when_not_specified
    prompt = RubyLLM::Text::KeyPoints.send(:build_prompt, @long_text, max_points: nil, format: :sentences)
    refute_includes prompt, "maximum"
  end

  def test_includes_format_instruction_for_bullets
    prompt = RubyLLM::Text::KeyPoints.send(:build_prompt, @long_text, max_points: nil, format: :bullets)
    assert_includes prompt, "bullet (•)"
  end

  def test_includes_format_instruction_for_numbers
    prompt = RubyLLM::Text::KeyPoints.send(:build_prompt, @long_text, max_points: nil, format: :numbers)
    assert_includes prompt, "numbered list"
  end

  def test_includes_format_instruction_for_sentences
    prompt = RubyLLM::Text::KeyPoints.send(:build_prompt, @long_text, max_points: nil, format: :sentences)
    assert_includes prompt, "complete sentences"
  end

  def test_parses_bullet_formatted_response
    response = "• First important point\n• Second key insight\n• Third major decision"
    RubyLLM::Text::Base.stubs(:call_llm).returns(response)

    result = RubyLLM::Text::KeyPoints.call(@long_text, format: :bullets)
    assert_equal [ "First important point", "Second key insight", "Third major decision" ], result
  end

  def test_parses_numbered_formatted_response
    response = "1. First important point\n2. Second key insight\n3. Third major decision"
    RubyLLM::Text::Base.stubs(:call_llm).returns(response)

    result = RubyLLM::Text::KeyPoints.call(@long_text, format: :numbers)
    assert_equal [ "First important point", "Second key insight", "Third major decision" ], result
  end

  def test_parses_sentence_formatted_response
    response = "First important point discussed.\nSecond key insight shared.\nThird major decision made."
    RubyLLM::Text::Base.stubs(:call_llm).returns(response)

    result = RubyLLM::Text::KeyPoints.call(@long_text, format: :sentences)
    assert_equal [ "First important point discussed.", "Second key insight shared.", "Third major decision made." ], result
  end

  def test_handles_empty_lines_in_response
    response = "First point\n\n\nSecond point\n\nThird point\n"
    RubyLLM::Text::Base.stubs(:call_llm).returns(response)

    result = RubyLLM::Text::KeyPoints.call(@long_text)
    assert_equal [ "First point", "Second point", "Third point" ], result
  end

  def test_uses_configured_model_when_specified
    RubyLLM::Text.configure do |config|
      config.key_points_model = "gpt-4.1-mini"
    end

    RubyLLM::Text::Base.expects(:call_llm).with(anything, model: "gpt-4.1-mini").returns("Point one\nPoint two")

    RubyLLM::Text::KeyPoints.call(@long_text)
  end

  def test_handles_mixed_formatting_in_response
    response = "• First point with bullet\n2. Second point with number\nThird point plain"
    RubyLLM::Text::Base.stubs(:call_llm).returns(response)

    result = RubyLLM::Text::KeyPoints.call(@long_text, format: :sentences)
    # Should clean based on format parameter, not actual content
    assert_equal [ "• First point with bullet", "2. Second point with number", "Third point plain" ], result
  end

  def test_defaults_to_sentences_format_for_unknown_format
    prompt = RubyLLM::Text::KeyPoints.send(:build_prompt, @long_text, max_points: nil, format: :unknown)
    assert_includes prompt, "complete sentences"
  end

  def test_handles_alternative_bullet_characters
    response = "* First point\n- Second point\n• Third point"
    RubyLLM::Text::Base.stubs(:call_llm).returns(response)

    result = RubyLLM::Text::KeyPoints.call(@long_text, format: :bullets)
    assert_equal [ "First point", "Second point", "Third point" ], result
  end
end
