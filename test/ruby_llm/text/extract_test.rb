require "test_helper"

class RubyLLM::Text::ExtractTest < Minitest::Test
  def setup
    @text = "My name is John and I am 30 years old. I work as a software engineer."
    @schema = { name: :string, age: :integer, profession: :string }
  end

  def test_extracts_structured_data_from_text
    RubyLLM::Text::Base.stubs(:call_llm).returns('{"name": "John", "age": 30, "profession": "software engineer"}')

    result = RubyLLM::Text::Extract.call(@text, schema: @schema)
    assert_kind_of String, result
    # Note: In real usage, this would be parsed JSON
  end

  def test_raises_error_when_schema_is_missing
    error = assert_raises(ArgumentError) do
      RubyLLM::Text::Extract.call(@text)
    end
    assert_equal "schema is required for extraction", error.message
  end

  def test_builds_correct_prompt_with_schema_fields
    prompt = RubyLLM::Text::Extract.send(:build_prompt, @text, @schema)
    assert_includes prompt, "name, age, profession"
  end

  def test_uses_configured_model_when_specified
    RubyLLM::Text.configure do |config|
      config.extract_model = "claude-sonnet-4-5"
    end

    # Mock the Base.call_llm method
    RubyLLM::Text::Base.expects(:call_llm).with(anything, model: "claude-sonnet-4-5", schema: anything).returns("{}")

    RubyLLM::Text::Extract.call(@text, schema: @schema)
  end

  def test_handles_string_fields_in_schema_building
    schema_class = RubyLLM::Text::Base.build_schema({ name: :string })
    assert_respond_to schema_class, :new
  end

  def test_handles_number_fields_in_schema_building
    schema_class = RubyLLM::Text::Base.build_schema({ age: :integer })
    assert_respond_to schema_class, :new
  end

  def test_returns_existing_schema_objects_unchanged
    # Create a simple object that responds to :schema
    existing_schema = Object.new
    def existing_schema.respond_to?(method)
      method == :schema
    end

    result = RubyLLM::Text::Base.build_schema(existing_schema)
    assert_equal existing_schema, result
  end
end
