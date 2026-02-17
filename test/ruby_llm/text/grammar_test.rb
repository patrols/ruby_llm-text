require "test_helper"

class RubyLLM::Text::GrammarTest < Minitest::Test
  def setup
    @text_with_errors = "Their going to the stor tommorow"
    @corrected_text = "They're going to the store tomorrow"
  end

  def test_fixes_grammar_and_spelling_errors
    RubyLLM::Text::Base.stubs(:call_llm).returns(@corrected_text)

    result = RubyLLM::Text::Grammar.call(@text_with_errors)
    assert_kind_of String, result
    assert_equal @corrected_text, result
  end

  def test_returns_structured_output_when_explain_is_true
    explanation_response = {
      "corrected" => @corrected_text,
      "changes" => ["Their → They're", "stor → store", "tommorow → tomorrow"]
    }.to_json

    RubyLLM::Text::Base.stubs(:call_llm).returns(explanation_response)

    result = RubyLLM::Text::Grammar.call(@text_with_errors, explain: true)
    assert_kind_of Hash, result
    assert_equal @corrected_text, result["corrected"]
    assert_kind_of Array, result["changes"]
    assert_equal 3, result["changes"].length
  end

  def test_includes_preserve_style_instruction_when_specified
    prompt = RubyLLM::Text::Grammar.send(:build_prompt, @text_with_errors, explain: false, preserve_style: true)
    assert_includes prompt, "Preserve the original tone, style, and level of formality"
  end

  def test_omits_preserve_style_instruction_when_not_specified
    prompt = RubyLLM::Text::Grammar.send(:build_prompt, @text_with_errors, explain: false, preserve_style: false)
    refute_includes prompt, "Preserve the original tone"
  end

  def test_includes_json_instruction_when_explain_is_true
    prompt = RubyLLM::Text::Grammar.send(:build_prompt, @text_with_errors, explain: true, preserve_style: false)
    assert_includes prompt, "JSON object"
    assert_includes prompt, "corrected"
    assert_includes prompt, "changes"
  end

  def test_requests_simple_output_when_explain_is_false
    prompt = RubyLLM::Text::Grammar.send(:build_prompt, @text_with_errors, explain: false, preserve_style: false)
    assert_includes prompt, "Return only the corrected text"
    refute_includes prompt, "JSON"
  end

  def test_uses_configured_model_when_specified
    RubyLLM::Text.configure do |config|
      config.grammar_model = "gpt-4.1-mini"
    end

    RubyLLM::Text::Base.expects(:call_llm).with(anything, model: "gpt-4.1-mini").returns(@corrected_text)

    RubyLLM::Text::Grammar.call(@text_with_errors)
  end

  def test_passes_schema_when_explain_is_true
    explanation_response = {
      "corrected" => @corrected_text,
      "changes" => ["Their → They're"]
    }.to_json

    # Just verify it gets called with a schema parameter
    RubyLLM::Text::Base.expects(:call_llm).with { |prompt, options|
      options.key?(:schema) && options[:schema][:type] == "object"
    }.returns(explanation_response)

    RubyLLM::Text::Grammar.call(@text_with_errors, explain: true)
  end
end