require "test_helper"

class RubyLLM::Text::GenerateTagsTest < Minitest::Test
  def setup
    @blog_post = "Ruby on Rails is a web application framework written in Ruby. It follows the Model-View-Controller (MVC) pattern and emphasizes convention over configuration."
    @tech_article = "Machine learning algorithms are transforming artificial intelligence and data science applications across industries."
  end

  def test_generates_tags_as_array
    response = "ruby\nrails\nweb development\nMVC\nframework"
    RubyLLM::Text::Base.stubs(:call_llm).returns(response)

    result = RubyLLM::Text::GenerateTags.call(@blog_post)

    assert_kind_of Array, result
    assert_equal 5, result.length
    assert_includes result, "ruby"
    assert_includes result, "web development"
  end

  def test_handles_comma_separated_response
    response = "machine learning, artificial intelligence, data science, algorithms"
    RubyLLM::Text::Base.stubs(:call_llm).returns(response)

    result = RubyLLM::Text::GenerateTags.call(@tech_article)

    assert_kind_of Array, result
    assert_equal 4, result.length
    assert_includes result, "machine learning"
    assert_includes result, "data science"
  end

  def test_cleans_formatting_markers
    response = "• programming\n- web development\n1. ruby\n2. rails"
    RubyLLM::Text::Base.stubs(:call_llm).returns(response)

    result = RubyLLM::Text::GenerateTags.call(@blog_post)

    assert_equal [ "programming", "web development", "ruby", "rails" ], result
  end

  def test_removes_duplicates
    response = "ruby\nrails\nruby\nweb development\nrails"
    RubyLLM::Text::Base.stubs(:call_llm).returns(response)

    result = RubyLLM::Text::GenerateTags.call(@blog_post)

    assert_equal [ "ruby", "rails", "web development" ], result
  end

  def test_handles_empty_lines_in_response
    response = "programming\n\n\nruby\n\nrails\n"
    RubyLLM::Text::Base.stubs(:call_llm).returns(response)

    result = RubyLLM::Text::GenerateTags.call(@blog_post)

    assert_equal [ "programming", "ruby", "rails" ], result
  end

  def test_respects_max_tags_parameter
    prompt = RubyLLM::Text::GenerateTags.send(:build_prompt, @blog_post, max_tags: 3, style: :keywords)

    assert_includes prompt, "maximum 3 tags"
  end

  def test_builds_prompt_for_keywords_style
    prompt = RubyLLM::Text::GenerateTags.send(:build_prompt, @blog_post, max_tags: nil, style: :keywords)

    assert_includes prompt, "Generate relevant keywords"
    assert_includes prompt, "simple words or short phrases"
    assert_includes prompt, @blog_post
  end

  def test_builds_prompt_for_topics_style
    prompt = RubyLLM::Text::GenerateTags.send(:build_prompt, @tech_article, max_tags: nil, style: :topics)

    assert_includes prompt, "broader topic categories"
    assert_includes prompt, "subject areas"
    assert_includes prompt, @tech_article
  end

  def test_builds_prompt_for_hashtags_style
    prompt = RubyLLM::Text::GenerateTags.send(:build_prompt, @blog_post, max_tags: 5, style: :hashtags)

    assert_includes prompt, "hashtag-style tags"
    assert_includes prompt, "include the # symbol"
    assert_includes prompt, "maximum 5 tags"
  end

  def test_handles_hashtag_formatted_response
    response = "#ruby\n#rails\n#webdevelopment\n#programming"
    RubyLLM::Text::Base.stubs(:call_llm).returns(response)

    result = RubyLLM::Text::GenerateTags.call(@blog_post, style: :hashtags)

    assert_includes result, "#ruby"
    assert_includes result, "#webdevelopment"
  end

  def test_removes_quotes_from_tags
    response = "\"programming\"\n\"web development\"\n\"ruby\""
    RubyLLM::Text::Base.stubs(:call_llm).returns(response)

    result = RubyLLM::Text::GenerateTags.call(@blog_post)

    assert_equal [ "programming", "web development", "ruby" ], result
  end

  def test_uses_configured_model_when_specified
    RubyLLM::Text.configure do |config|
      config.generate_tags_model = "gpt-4o-mini"
    end

    RubyLLM::Text::Base.expects(:call_llm).with(anything, model: "gpt-4o-mini").returns("ruby\nrails")
    RubyLLM::Text::GenerateTags.call(@blog_post)
  end

  def test_module_level_api_delegates_correctly
    RubyLLM::Text::Base.stubs(:call_llm).returns("tech\nAI\ndata")

    result = RubyLLM::Text.generate_tags(@tech_article, max_tags: 3)

    assert_equal [ "tech", "AI", "data" ], result
  end

  def test_defaults_to_keywords_style_for_unknown_style
    prompt = RubyLLM::Text::GenerateTags.send(:build_prompt, @blog_post, max_tags: nil, style: :unknown)

    assert_includes prompt, "Generate relevant keywords"
  end
end
