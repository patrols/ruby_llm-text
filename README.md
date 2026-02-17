# ruby_llm-text

ActiveSupport-style LLM utilities for Ruby that make AI operations feel like native Ruby.

[![Gem Version](https://badge.fury.io/rb/ruby_llm-text.svg)](https://badge.fury.io/rb/ruby_llm-text)
[![CI](https://github.com/patrols/ruby_llm-text/workflows/CI/badge.svg)](https://github.com/patrols/ruby_llm-text/actions)

## Overview

`ruby_llm-text` provides intuitive one-liner utility methods for common LLM tasks including text summarization, translation, data extraction, classification, grammar correction, sentiment analysis, key point extraction, text rewriting, and question answering. It integrates seamlessly with the [ruby_llm](https://github.com/crmne/ruby_llm) ecosystem, providing a simple interface without requiring chat objects, message arrays, or configuration boilerplate.

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

# Fix grammar and spelling
corrected = RubyLLM::Text.fix_grammar("Their going to the stor tommorow")

# Get sentiment with confidence
sentiment_analysis = RubyLLM::Text.sentiment("I love this product!")
# => {"label" => "positive", "confidence" => 0.95}

# Extract key points from long text
points = RubyLLM::Text.key_points("Long meeting notes...", max_points: 3)
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

### Fix Grammar

Correct grammar, spelling, and punctuation errors.

```ruby
RubyLLM::Text.fix_grammar(text, explain: false, preserve_style: false, model: nil)
```

**Parameters:**

- `text` (String): The text to correct
- `explain` (Boolean, optional): Return explanations of changes made (default: false)
- `preserve_style` (Boolean, optional): Keep original tone and style (default: false)
- `model` (String, optional): Specific model to use

**Examples:**

```ruby
# Basic grammar correction
RubyLLM::Text.fix_grammar("Their going to the stor tommorow")
# => "They're going to the store tomorrow"

# With explanations
result = RubyLLM::Text.fix_grammar("bad grammer here", explain: true)
# => {"corrected" => "bad grammar here", "changes" => ["grammer → grammar"]}

# Preserve casual style
RubyLLM::Text.fix_grammar("hey whats up", preserve_style: true)
# => "Hey, what's up?" (keeps casual tone)
```

### Sentiment

Analyze sentiment with confidence scores.

```ruby
RubyLLM::Text.sentiment(text, categories: ["positive", "negative", "neutral"], simple: false, model: nil)
```

**Parameters:**

- `text` (String): The text to analyze
- `categories` (Array, optional): Custom sentiment categories (default: positive/negative/neutral)
- `simple` (Boolean, optional): Return just the label without confidence (default: false)
- `model` (String, optional): Specific model to use

**Examples:**

```ruby
# Basic sentiment analysis with confidence
RubyLLM::Text.sentiment("I love this product!")
# => {"label" => "positive", "confidence" => 0.95}

# Simple mode (just the label)
RubyLLM::Text.sentiment("Great service!", simple: true)
# => "positive"

# Custom categories
RubyLLM::Text.sentiment("I'm excited about tomorrow!",
  categories: ["excited", "calm", "worried", "neutral"])
# => {"label" => "excited", "confidence" => 0.92}
```

### Key Points

Extract main points from longer text.

```ruby
RubyLLM::Text.key_points(text, max_points: nil, format: :sentences, model: nil)
```

**Parameters:**

- `text` (String): The text to extract points from
- `max_points` (Integer, optional): Maximum number of points to extract
- `format` (Symbol, optional): Output format (`:sentences`, `:bullets`, `:numbers`)
- `model` (String, optional): Specific model to use

**Examples:**

```ruby
# Basic key points extraction
meeting_notes = "We discussed budget, hiring, and marketing plans..."
points = RubyLLM::Text.key_points(meeting_notes)
# => ["Budget allocation reviewed", "New hiring plans discussed", ...]

# Limit number of points
RubyLLM::Text.key_points(text, max_points: 3)

# Different formats
RubyLLM::Text.key_points(text, format: :bullets)   # Returns clean text
RubyLLM::Text.key_points(text, format: :numbers)   # Returns clean text
RubyLLM::Text.key_points(text, format: :sentences) # Returns clean sentences
```

### Rewrite

Transform text tone and style.

```ruby
RubyLLM::Text.rewrite(text, tone: nil, style: nil, instruction: nil, model: nil)
```

**Parameters:**

- `text` (String): The text to rewrite
- `tone` (Symbol|String, optional): Target tone (`:professional`, `:casual`, `:academic`, `:creative`)
- `style` (Symbol|String, optional): Target style (`:concise`, `:detailed`, `:formal`)
- `instruction` (String, optional): Custom rewriting instruction
- `model` (String, optional): Specific model to use

**Examples:**

```ruby
# Change tone
RubyLLM::Text.rewrite("hey whats up", tone: :professional)
# => "Good morning. How are you doing?"

# Change style
RubyLLM::Text.rewrite("This is a long explanation...", style: :concise)
# => "Brief explanation."

# Custom instructions
RubyLLM::Text.rewrite("Hello there", instruction: "make it sound like a pirate")
# => "Ahoy there, matey!"

# Combine multiple transformations
RubyLLM::Text.rewrite(text, tone: :professional, style: :concise)
```

### Answer

Answer questions based on provided text.

```ruby
RubyLLM::Text.answer(text, question, include_confidence: false, model: nil)
```

**Parameters:**

- `text` (String): The text to search for answers
- `question` (String): The question to answer
- `include_confidence` (Boolean, optional): Include confidence score (default: false)
- `model` (String, optional): Specific model to use

**Examples:**

```ruby
article = "Ruby was created by Yukihiro Matsumoto in 1995..."

# Basic question answering
RubyLLM::Text.answer(article, "Who created Ruby?")
# => "Yukihiro Matsumoto"

# Boolean questions
RubyLLM::Text.answer(article, "Is Ruby a programming language?")
# => true

# With confidence scores
result = RubyLLM::Text.answer(article, "When was Ruby created?", include_confidence: true)
# => {"answer" => "1995", "confidence" => 0.98}

# When answer not found
RubyLLM::Text.answer(article, "What is Python?")
# => "information not available"
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
  config.grammar_model = "gpt-4.1-mini"         # Good for grammar correction
  config.sentiment_model = "claude-haiku-4-5"   # Fast for sentiment analysis
  config.key_points_model = "gpt-4.1-mini"      # Good for summarization tasks
  config.rewrite_model = "gpt-4.1"              # Creative rewriting tasks
  config.answer_model = "claude-sonnet-4-5"     # Strong reasoning for Q&A
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
"Their going to the stor".fix_grammar
"I love this!".sentiment
"Long meeting notes...".key_points(max_points: 3)
"hey whats up".rewrite(tone: :professional)
"Ruby was created in 1995".answer("When was Ruby created?")
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
RubyLLM::Text.answer("text", nil)  # ArgumentError: question is required
RubyLLM::Text.rewrite("text")  # ArgumentError: Must specify tone, style, or instruction

# API errors are wrapped with context
RubyLLM::Text.summarize("text")  # RubyLLM::Text::Error: LLM call failed: [original error]

# Graceful fallbacks for parsing issues
RubyLLM::Text.sentiment("text")  # Falls back to simple mode if JSON parsing fails
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

This script tests all nine methods with real LLM APIs and provides helpful output for verification.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/patrols/ruby_llm-text.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
