require "test_helper"

class RubyLLM::Text::ValidationTest < Minitest::Test
  # Test validate_text!
  def test_validate_text_raises_on_nil
    error = assert_raises(RubyLLM::Text::Validation::ValidationError) do
      RubyLLM::Text::Validation.validate_text!(nil)
    end
    assert_equal "text cannot be nil", error.message
  end

  def test_validate_text_raises_on_empty_string
    error = assert_raises(RubyLLM::Text::Validation::ValidationError) do
      RubyLLM::Text::Validation.validate_text!("")
    end
    assert_equal "text cannot be empty", error.message
  end

  def test_validate_text_raises_on_whitespace_only
    error = assert_raises(RubyLLM::Text::Validation::ValidationError) do
      RubyLLM::Text::Validation.validate_text!("   \n\t  ")
    end
    assert_equal "text cannot be empty", error.message
  end

  def test_validate_text_raises_on_non_string
    error = assert_raises(RubyLLM::Text::Validation::ValidationError) do
      RubyLLM::Text::Validation.validate_text!(123)
    end
    assert_equal "text must be a String, got Integer", error.message
  end

  def test_validate_text_uses_custom_param_name
    error = assert_raises(RubyLLM::Text::Validation::ValidationError) do
      RubyLLM::Text::Validation.validate_text!(nil, param_name: "question")
    end
    assert_equal "question cannot be nil", error.message
  end

  def test_validate_text_passes_for_valid_string
    assert_nil RubyLLM::Text::Validation.validate_text!("Hello world")
  end

  # Test validate_required!
  def test_validate_required_raises_on_nil
    error = assert_raises(RubyLLM::Text::Validation::ValidationError) do
      RubyLLM::Text::Validation.validate_required!(nil, "schema")
    end
    assert_equal "schema is required", error.message
  end

  def test_validate_required_passes_for_any_value
    assert_nil RubyLLM::Text::Validation.validate_required!("value", "param")
    assert_nil RubyLLM::Text::Validation.validate_required!([], "param")
    assert_nil RubyLLM::Text::Validation.validate_required!(false, "param")
  end

  # Test validate_array!
  def test_validate_array_raises_on_nil
    error = assert_raises(RubyLLM::Text::Validation::ValidationError) do
      RubyLLM::Text::Validation.validate_array!(nil, "categories")
    end
    assert_equal "categories is required", error.message
  end

  def test_validate_array_raises_on_non_array
    error = assert_raises(RubyLLM::Text::Validation::ValidationError) do
      RubyLLM::Text::Validation.validate_array!("not an array", "categories")
    end
    assert_equal "categories must be an Array, got String", error.message
  end

  def test_validate_array_raises_on_empty_array
    error = assert_raises(RubyLLM::Text::Validation::ValidationError) do
      RubyLLM::Text::Validation.validate_array!([], "categories")
    end
    assert_equal "categories must have at least 1 element(s)", error.message
  end

  def test_validate_array_respects_min_size
    error = assert_raises(RubyLLM::Text::Validation::ValidationError) do
      RubyLLM::Text::Validation.validate_array!([ "one" ], "categories", min_size: 2)
    end
    assert_equal "categories must have at least 2 element(s)", error.message
  end

  def test_validate_array_passes_for_valid_array
    assert_nil RubyLLM::Text::Validation.validate_array!([ "a", "b" ], "categories")
  end

  # Test validate_one_of!
  def test_validate_one_of_raises_when_all_nil
    error = assert_raises(RubyLLM::Text::Validation::ValidationError) do
      RubyLLM::Text::Validation.validate_one_of!({ tone: nil, style: nil }, %w[tone style])
    end
    assert_equal "must specify at least one of: tone, style", error.message
  end

  def test_validate_one_of_passes_when_one_present
    assert_nil RubyLLM::Text::Validation.validate_one_of!({ tone: :casual, style: nil }, %w[tone style])
  end

  # Test ValidationError is a subclass of Error
  def test_validation_error_is_subclass_of_error
    assert RubyLLM::Text::Validation::ValidationError < RubyLLM::Text::Error
  end

  # Integration tests - operations validate their inputs
  def test_summarize_validates_text
    assert_raises(RubyLLM::Text::Validation::ValidationError) do
      RubyLLM::Text.summarize(nil)
    end
  end

  def test_translate_validates_text
    assert_raises(RubyLLM::Text::Validation::ValidationError) do
      RubyLLM::Text.translate(nil, to: "French")
    end
  end

  def test_translate_validates_to_param
    assert_raises(RubyLLM::Text::Validation::ValidationError) do
      RubyLLM::Text.translate("Hello", to: nil)
    end
  end

  def test_extract_validates_text
    assert_raises(RubyLLM::Text::Validation::ValidationError) do
      RubyLLM::Text.extract(nil, schema: { name: :string })
    end
  end

  def test_extract_validates_schema
    assert_raises(RubyLLM::Text::Validation::ValidationError) do
      RubyLLM::Text.extract("Hello", schema: nil)
    end
  end

  def test_classify_validates_text
    assert_raises(RubyLLM::Text::Validation::ValidationError) do
      RubyLLM::Text.classify(nil, categories: [ "a", "b" ])
    end
  end

  def test_classify_validates_categories
    assert_raises(RubyLLM::Text::Validation::ValidationError) do
      RubyLLM::Text.classify("Hello", categories: [])
    end
  end

  def test_answer_validates_text
    assert_raises(RubyLLM::Text::Validation::ValidationError) do
      RubyLLM::Text.answer(nil, "What?")
    end
  end

  def test_answer_validates_question
    assert_raises(RubyLLM::Text::Validation::ValidationError) do
      RubyLLM::Text.answer("Hello", nil)
    end
  end

  def test_rewrite_validates_text
    assert_raises(RubyLLM::Text::Validation::ValidationError) do
      RubyLLM::Text.rewrite(nil, tone: :casual)
    end
  end

  def test_rewrite_validates_options
    assert_raises(RubyLLM::Text::Validation::ValidationError) do
      RubyLLM::Text.rewrite("Hello")
    end
  end

  def test_compare_validates_text1
    assert_raises(RubyLLM::Text::Validation::ValidationError) do
      RubyLLM::Text.compare(nil, "text2")
    end
  end

  def test_compare_validates_text2
    assert_raises(RubyLLM::Text::Validation::ValidationError) do
      RubyLLM::Text.compare("text1", nil)
    end
  end

  def test_detect_language_validates_text
    assert_raises(RubyLLM::Text::Validation::ValidationError) do
      RubyLLM::Text.detect_language(nil)
    end
  end

  def test_generate_tags_validates_text
    assert_raises(RubyLLM::Text::Validation::ValidationError) do
      RubyLLM::Text.generate_tags(nil)
    end
  end

  def test_anonymize_validates_text
    assert_raises(RubyLLM::Text::Validation::ValidationError) do
      RubyLLM::Text.anonymize(nil)
    end
  end

  def test_fix_grammar_validates_text
    assert_raises(RubyLLM::Text::Validation::ValidationError) do
      RubyLLM::Text.fix_grammar(nil)
    end
  end

  def test_sentiment_validates_text
    assert_raises(RubyLLM::Text::Validation::ValidationError) do
      RubyLLM::Text.sentiment(nil)
    end
  end

  def test_key_points_validates_text
    assert_raises(RubyLLM::Text::Validation::ValidationError) do
      RubyLLM::Text.key_points(nil)
    end
  end
end
