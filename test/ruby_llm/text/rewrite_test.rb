require "test_helper"

class RubyLLM::Text::RewriteTest < Minitest::Test
  def setup
    @casual_text = "hey u free tmrw?"
    @professional_text = "Are you available tomorrow?"
  end

  def test_rewrites_text_with_tone_parameter
    RubyLLM::Text::Base.stubs(:call_llm).returns(@professional_text)

    result = RubyLLM::Text::Rewrite.call(@casual_text, tone: :professional)
    assert_kind_of String, result
    assert_equal @professional_text, result
  end

  def test_rewrites_text_with_style_parameter
    RubyLLM::Text::Base.stubs(:call_llm).returns("Brief message.")

    result = RubyLLM::Text::Rewrite.call("This is a long detailed message with lots of information.", style: :concise)
    assert_kind_of String, result
  end

  def test_rewrites_text_with_custom_instruction
    RubyLLM::Text::Base.stubs(:call_llm).returns("Ahoy matey, be ye free on the morrow?")

    result = RubyLLM::Text::Rewrite.call(@casual_text, instruction: "make it sound like a pirate")
    assert_kind_of String, result
  end

  def test_raises_error_when_no_transformation_specified
    assert_raises(ArgumentError) do
      RubyLLM::Text::Rewrite.call(@casual_text)
    end
  end

  def test_includes_predefined_tone_description_in_prompt
    prompt = RubyLLM::Text::Rewrite.send(:build_prompt, @casual_text, tone: :professional, style: nil, instruction: nil)
    assert_includes prompt, "business-appropriate, formal, and polished"
  end

  def test_includes_custom_tone_description_in_prompt
    prompt = RubyLLM::Text::Rewrite.send(:build_prompt, @casual_text, tone: "sarcastic", style: nil, instruction: nil)
    assert_includes prompt, "sarcastic"
  end

  def test_includes_predefined_style_description_in_prompt
    prompt = RubyLLM::Text::Rewrite.send(:build_prompt, @casual_text, tone: nil, style: :concise, instruction: nil)
    assert_includes prompt, "shorter and more direct"
  end

  def test_includes_custom_style_description_in_prompt
    prompt = RubyLLM::Text::Rewrite.send(:build_prompt, @casual_text, tone: nil, style: "poetic", instruction: nil)
    assert_includes prompt, "poetic"
  end

  def test_includes_custom_instruction_in_prompt
    custom_instruction = "make it sound like Shakespeare"
    prompt = RubyLLM::Text::Rewrite.send(:build_prompt, @casual_text, tone: nil, style: nil, instruction: custom_instruction)
    assert_includes prompt, custom_instruction
  end

  def test_combines_multiple_transformations_in_prompt
    prompt = RubyLLM::Text::Rewrite.send(:build_prompt, @casual_text, tone: :professional, style: :concise, instruction: "add urgency")
    assert_includes prompt, "business-appropriate"
    assert_includes prompt, "shorter and more direct"
    assert_includes prompt, "add urgency"
  end

  def test_handles_tone_and_style_combination
    RubyLLM::Text::Base.stubs(:call_llm).returns("Professional brief message.")

    result = RubyLLM::Text::Rewrite.call(@casual_text, tone: :professional, style: :concise)
    assert_kind_of String, result
  end

  def test_handles_tone_and_instruction_combination
    RubyLLM::Text::Base.stubs(:call_llm).returns("Are you available tomorrow? Please respond ASAP.")

    result = RubyLLM::Text::Rewrite.call(@casual_text, tone: :professional, instruction: "add urgency")
    assert_kind_of String, result
  end

  def test_uses_configured_model_when_specified
    RubyLLM::Text.configure do |config|
      config.rewrite_model = "gpt-4.1-mini"
    end

    RubyLLM::Text::Base.expects(:call_llm).with(anything, model: "gpt-4.1-mini").returns(@professional_text)

    RubyLLM::Text::Rewrite.call(@casual_text, tone: :professional)
  end

  def test_supports_all_predefined_tones
    RubyLLM::Text::Rewrite::TONES.each do |tone, description|
      prompt = RubyLLM::Text::Rewrite.send(:build_prompt, @casual_text, tone: tone, style: nil, instruction: nil)
      assert_includes prompt, description, "Should include description for tone #{tone}"
    end
  end

  def test_supports_all_predefined_styles
    RubyLLM::Text::Rewrite::STYLES.each do |style, description|
      prompt = RubyLLM::Text::Rewrite.send(:build_prompt, @casual_text, tone: nil, style: style, instruction: nil)
      assert_includes prompt, description, "Should include description for style #{style}"
    end
  end

  def test_prompt_requests_only_rewritten_text
    prompt = RubyLLM::Text::Rewrite.send(:build_prompt, @casual_text, tone: :professional, style: nil, instruction: nil)
    assert_includes prompt, "Return only the rewritten text"
    assert_includes prompt, "no explanation or commentary"
  end
end
