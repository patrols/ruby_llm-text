# ruby_llm-text

ActiveSupport-style LLM utilities for Ruby that make AI operations feel like native Ruby.

[![Gem Version](https://badge.fury.io/rb/ruby_llm-text.svg)](https://badge.fury.io/rb/ruby_llm-text)
[![CI](https://github.com/patrols/ruby_llm-text/workflows/CI/badge.svg)](https://github.com/patrols/ruby_llm-text/actions)

## Overview

`ruby_llm-text` provides intuitive one-liner utility methods for common LLM tasks like summarizing text, translation, data extraction, and classification. It integrates seamlessly with the [ruby_llm](https://github.com/crmne/ruby_llm) ecosystem, providing a simple interface without requiring chat objects, message arrays, or configuration boilerplate.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ruby_llm-text'
```

And then execute:

```bash
$ bundle install
```

Or install it yourself as:

```bash
$ gem install ruby_llm-text
```

## Quick Start

```ruby
require 'ruby_llm/text'

# Configure ruby_llm with your API key
RubyLLM.configure do |config|
  config.openai_api_key = ENV["OPENAI_API_KEY"]
end

# Summarize text
long_article = "This is a very long article about..."
summary = RubyLLM::Text.summarize(long_article)

# Translate text
greeting = RubyLLM::Text.translate("Bonjour le monde", to: "en")

# Extract structured data
text = "My name is John and I am 30 years old."
data = RubyLLM::Text.extract(text, schema: { name: :string, age: :integer })

# Classify text
review = "This product is amazing!"
sentiment = RubyLLM::Text.classify(review, categories: ["positive", "negative", "neutral"])
```

## API Reference

### Summarize

Condense text into a shorter summary.

```ruby
RubyLLM::Text.summarize(text, length: :medium, max_words: nil, model: nil)
```

**Parameters:**
- `text` (String): The text to summarize
- `length` (Symbol|String): Predefined length (`:short`, `:medium`, `:detailed`) or custom description
- `max_words` (Integer, optional): Maximum word count for summary
- `model` (String, optional): Specific model to use

**Examples:**
```ruby
# Basic usage
RubyLLM::Text.summarize("Long article text...")

# With length option
RubyLLM::Text.summarize(text, length: :short)

# With word limit
RubyLLM::Text.summarize(text, length: :medium, max_words: 50)

# Custom length description
RubyLLM::Text.summarize(text, length: "bullet points")
```

### Translate

Translate text between languages.

```ruby
RubyLLM::Text.translate(text, to:, from: nil, model: nil)
```

**Parameters:**
- `text` (String): The text to translate
- `to` (String): Target language (e.g., "en", "spanish", "français")
- `from` (String, optional): Source language for better accuracy
- `model` (String, optional): Specific model to use

**Examples:**
```ruby
# Basic translation
RubyLLM::Text.translate("Bonjour", to: "en")

# With source language specified
RubyLLM::Text.translate("Hola mundo", to: "en", from: "es")

# Natural language specifications
RubyLLM::Text.translate("Hello", to: "french")
```

### Extract

Extract structured data from unstructured text.

```ruby
RubyLLM::Text.extract(text, schema:, model: nil)
```

**Parameters:**
- `text` (String): The text to extract data from
- `schema` (Hash): Data structure specification
- `model` (String, optional): Specific model to use

**Schema Types:**
- `:string` - Text fields
- `:integer`, `:number` - Numeric fields
- `:boolean` - True/false fields
- `:array` - List fields

**Examples:**
```ruby
# Extract person details
text = "John Smith is 30 years old and works as a software engineer in San Francisco."
schema = {
  name: :string,
  age: :integer,
  profession: :string,
  location: :string
}
data = RubyLLM::Text.extract(text, schema: schema)

# Extract product information
product_text = "iPhone 15 Pro costs $999 and has excellent reviews"
product_schema = {
  name: :string,
  price: :number,
  currency: :string,
  reviews: :array
}
product_data = RubyLLM::Text.extract(product_text, schema: product_schema)
```

### Classify

Classify text into predefined categories.

```ruby
RubyLLM::Text.classify(text, categories:, model: nil)
```

**Parameters:**
- `text` (String): The text to classify
- `categories` (Array): List of possible categories
- `model` (String, optional): Specific model to use

**Examples:**
```ruby
# Sentiment analysis
review = "This product exceeded my expectations!"
sentiment = RubyLLM::Text.classify(review,
  categories: ["positive", "negative", "neutral"]
)

# Topic classification
article = "The stock market reached new highs today..."
topic = RubyLLM::Text.classify(article,
  categories: ["technology", "finance", "sports", "politics"]
)

# Priority classification
email = "URGENT: Server is down and customers can't access the site"
priority = RubyLLM::Text.classify(email,
  categories: ["low", "medium", "high", "critical"]
)
```

## Configuration

This gem uses `ruby_llm`'s configuration for API keys and default models:

```ruby
# Configure ruby_llm (API keys, default model, etc.)
RubyLLM.configure do |config|
  config.openai_api_key = ENV["OPENAI_API_KEY"]
  config.anthropic_api_key = ENV["ANTHROPIC_API_KEY"]
  config.default_model = "gpt-4.1-mini"
end
```

Optionally configure text-specific settings:

```ruby
RubyLLM::Text.configure do |config|
  # Temperature for text operations (default: 0.3)
  config.temperature = 0.3

  # Method-specific model overrides (falls back to RubyLLM.config.default_model)
  config.summarize_model = "gpt-4.1-mini"
  config.translate_model = "claude-sonnet-4-5"  # Use Claude for translation
  config.extract_model = "gpt-4.1"              # Use GPT-4 for extraction
  config.classify_model = "gpt-4.1-mini"
end
```

**Per-call overrides:**
```ruby
# Override model for specific calls
RubyLLM::Text.summarize(text, model: "claude-sonnet-4-5")

# Pass additional options (passed through to ruby_llm)
RubyLLM::Text.translate(text, to: "es", temperature: 0.1)
```

## String Extensions (Optional)

For a more Rails-like experience, you can enable String monkey-patching:

```ruby
require 'ruby_llm/text/string_ext'

# Now you can call methods directly on strings
"Long article text...".summarize
"Bonjour".translate(to: "en")
"John is 30".extract(schema: { name: :string, age: :integer })
"Great product!".classify(categories: ["positive", "negative"])
```

## Integration with ruby_llm

This gem builds on top of [ruby_llm](https://github.com/crmne/ruby_llm) and inherits its configuration and model support:

- **Models**: Supports all ruby_llm models (OpenAI GPT, Anthropic Claude, etc.)
- **Configuration**: Uses ruby_llm's underlying configuration system
- **Error handling**: Inherits ruby_llm's robust error handling

## Error Handling

The gem provides clear error messages for common issues:

```ruby
# Missing required parameters
RubyLLM::Text.extract("text")  # ArgumentError: schema is required

RubyLLM::Text.classify("text", categories: [])  # ArgumentError: categories are required

# API errors are wrapped with context
RubyLLM::Text.summarize("text")  # RubyLLM::Text::Error: LLM call failed: [original error]
```

## Development

After checking out the repo, run:

```bash
bin/setup      # Install dependencies
rake test      # Run tests
rake rubocop   # Run linter
rake           # Run tests and linter
```

## Testing

The test suite uses Mocha for mocking LLM API calls, ensuring reliable and fast tests without requiring API keys:

```bash
# Run all tests
bundle exec rake test

# Run tests with linting
bundle exec rake

# Run linting only
bundle exec rubocop
```

### Manual Testing

For manual testing with real API calls, use the provided test script:

```bash
# Set up your API key
export OPENAI_API_KEY="your-key"
# or
export ANTHROPIC_API_KEY="your-key"

# Run manual tests
bin/manual-test
```

This script tests all four methods with real LLM APIs and provides helpful output for verification.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/patrols/ruby_llm-text.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
