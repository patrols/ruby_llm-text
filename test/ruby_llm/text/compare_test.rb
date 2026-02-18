require "test_helper"

class RubyLLM::Text::CompareTest < Minitest::Test
  def setup
    @text1 = "Ruby is a dynamic programming language with a focus on simplicity and productivity."
    @text2 = "Ruby is an elegant programming language that emphasizes developer happiness and ease of use."
    @different_text1 = "The weather today is sunny and warm."
    @different_text2 = "Machine learning algorithms are transforming artificial intelligence."
  end

  def test_compares_texts_with_similarity_response
    similarity_response = {
      "similarity" => 0.85,
      "comparison_type" => "similarity",
      "similarity_type" => "semantic",
      "summary" => "Both texts describe Ruby programming language positively."
    }.to_json

    RubyLLM::Text::Base.stubs(:call_llm).returns(similarity_response)

    result = RubyLLM::Text::Compare.call(@text1, @text2)

    assert_kind_of Hash, result
    assert_equal 0.85, result["similarity"]
    assert_equal "similarity", result["comparison_type"]
    assert result["similarity"].is_a?(Float)
  end

  def test_compares_texts_with_detailed_response
    detailed_response = {
      "similarity" => 0.75,
      "comparison_type" => "detailed",
      "differences" => [ "tone", "word choice" ],
      "commonalities" => [ "topic", "positive sentiment" ],
      "summary" => "Similar content with different presentation styles."
    }.to_json

    RubyLLM::Text::Base.stubs(:call_llm).returns(detailed_response)

    result = RubyLLM::Text::Compare.call(@text1, @text2, comparison_type: :detailed)

    assert_kind_of Hash, result
    assert_equal 0.75, result["similarity"]
    assert_equal "detailed", result["comparison_type"]
    assert_kind_of Array, result["differences"]
    assert_kind_of Array, result["commonalities"]
    assert_includes result["differences"], "tone"
    assert_includes result["commonalities"], "topic"
  end

  def test_compares_texts_with_changes_response
    changes_response = {
      "similarity" => 0.60,
      "comparison_type" => "changes",
      "change_types" => [ "word substitution", "tone modification" ],
      "examples" => [ "'focus on simplicity' → 'emphasizes developer happiness'" ],
      "assessment" => "Minor improvements in clarity and expressiveness."
    }.to_json

    RubyLLM::Text::Base.stubs(:call_llm).returns(changes_response)

    result = RubyLLM::Text::Compare.call(@text1, @text2, comparison_type: :changes)

    assert_kind_of Hash, result
    assert_equal 0.60, result["similarity"]
    assert_equal "changes", result["comparison_type"]
    assert_kind_of Array, result["change_types"]
    assert_kind_of Array, result["examples"]
    assert_includes result["change_types"], "word substitution"
  end

  def test_handles_json_parsing_failure_gracefully
    RubyLLM::Text::Base.stubs(:call_llm).returns("Invalid JSON response")

    result = RubyLLM::Text::Compare.call(@text1, @text2)

    assert_kind_of Hash, result
    assert_nil result["similarity"]
    assert_equal "similarity", result["comparison_type"]
    assert result.key?("error")
  end

  def test_converts_similarity_to_float
    similarity_response = {
      "similarity" => 1,
      "comparison_type" => "similarity"
    }.to_json

    RubyLLM::Text::Base.stubs(:call_llm).returns(similarity_response)

    result = RubyLLM::Text::Compare.call(@text1, @text2)

    assert_equal 1.0, result["similarity"]
    assert result["similarity"].is_a?(Float)
  end

  def test_builds_prompt_for_similarity_comparison
    prompt = RubyLLM::Text::Compare.send(:build_prompt, @text1, @text2, comparison_type: :similarity)

    assert_includes prompt, "Compare the two texts"
    assert_includes prompt, "similarity score from 0 to 1"
    assert_includes prompt, "semantic similarity"
    assert_includes prompt, @text1
    assert_includes prompt, @text2
    assert_includes prompt, "Text 1:"
    assert_includes prompt, "Text 2:"
  end

  def test_builds_prompt_for_detailed_comparison
    prompt = RubyLLM::Text::Compare.send(:build_prompt, @text1, @text2, comparison_type: :detailed)

    assert_includes prompt, "detailed comparison"
    assert_includes prompt, "differences between the texts"
    assert_includes prompt, "Common elements"
    assert_includes prompt, "style, tone, content, structure"
  end

  def test_builds_prompt_for_changes_comparison
    prompt = RubyLLM::Text::Compare.send(:build_prompt, @text1, @text2, comparison_type: :changes)

    assert_includes prompt, "revision of the first"
    assert_includes prompt, "changes made"
    assert_includes prompt, "additions, deletions, modifications"
    assert_includes prompt, "tracking edits"
  end

  def test_builds_correct_schema_for_similarity
    schema = RubyLLM::Text::Compare.send(:build_comparison_schema, :similarity)

    assert_equal "object", schema[:type]
    assert schema[:properties].key?(:similarity)
    assert schema[:properties].key?(:similarity_type)
    assert schema[:properties].key?(:summary)
    assert_includes schema[:required], "similarity"
  end

  def test_builds_correct_schema_for_detailed
    schema = RubyLLM::Text::Compare.send(:build_comparison_schema, :detailed)

    assert schema[:properties].key?(:differences)
    assert schema[:properties].key?(:commonalities)
    assert_equal "array", schema[:properties][:differences][:type]
    assert_equal "array", schema[:properties][:commonalities][:type]
  end

  def test_builds_correct_schema_for_changes
    schema = RubyLLM::Text::Compare.send(:build_comparison_schema, :changes)

    assert schema[:properties].key?(:change_types)
    assert schema[:properties].key?(:examples)
    assert schema[:properties].key?(:assessment)
    assert_equal "array", schema[:properties][:change_types][:type]
  end

  def test_always_passes_schema_for_structured_output
    RubyLLM::Text::Base.expects(:call_llm).with { |prompt, options|
      options.key?(:schema) &&
      options[:schema][:type] == "object" &&
      options[:schema][:properties].key?(:similarity)
    }.returns('{"similarity": 0.8, "comparison_type": "similarity"}')

    RubyLLM::Text::Compare.call(@text1, @text2)
  end

  def test_uses_configured_model_when_specified
    RubyLLM::Text.configure do |config|
      config.compare_model = "claude-3-5-sonnet"
    end

    RubyLLM::Text::Base.expects(:call_llm).with { |prompt, options|
      options[:model] == "claude-3-5-sonnet"
    }.returns('{"similarity": 0.9, "comparison_type": "similarity"}')
    RubyLLM::Text::Compare.call(@text1, @text2)
  end

  def test_module_level_api_delegates_correctly
    response = '{"similarity": 0.7, "comparison_type": "similarity"}'
    RubyLLM::Text::Base.stubs(:call_llm).returns(response)

    result = RubyLLM::Text.compare(@text1, @text2, comparison_type: :detailed)

    assert_equal 0.7, result["similarity"]
  end

  def test_defaults_to_similarity_for_unknown_comparison_type
    prompt = RubyLLM::Text::Compare.send(:build_prompt, @text1, @text2, comparison_type: :unknown)

    assert_includes prompt, "similarity score from 0 to 1"
    assert_includes prompt, "semantic similarity"
  end
end
