# AI.md - Context for AI Assistants

## Project Overview

`ruby_llm-text` is a Ruby gem that provides ActiveSupport-style LLM utilities. It offers intuitive one-liner methods for common text operations powered by LLMs, making AI operations feel like native Ruby.

**Repository:** https://github.com/patrols/ruby_llm-text
**License:** MIT
**Ruby:** >= 3.2.0
**Core Dependency:** ruby_llm (~> 1.0)

## Architecture

### Directory Structure

```
lib/ruby_llm/
├── text.rb              # Main module, public API entry point
└── text/
    ├── base.rb          # Shared LLM calling logic & schema building
    ├── configuration.rb # Text-specific configuration
    ├── validation.rb    # Input validation helpers
    ├── string_ext.rb    # Optional String monkey-patching
    └── [operation].rb   # Individual operation modules
```

### Operation Pattern

Each operation follows a consistent pattern:

1. Module under `RubyLLM::Text::[OperationName]`
2. Class method `self.call(text, **options)` as entry point
3. Uses `Validation.validate_text!` for input validation
4. Calls `Base.call_llm(prompt, model:, **options)` to execute
5. Returns processed result (string, hash, or array depending on operation)

Example operation file structure:
```ruby
module RubyLLM::Text::[OperationName]
  def self.call(text, **options)
    Validation.validate_text!(text)
    model ||= RubyLLM::Text.config.model_for(:operation_name)
    prompt = build_prompt(text, **options)
    Base.call_llm(prompt, model: model, **options)
  end

  def self.build_prompt(text, **options)
    # Build LLM prompt
  end
end
```

### Available Operations

| Method | Description |
|--------|-------------|
| `summarize` | Condense text to shorter summary |
| `translate` | Translate between languages |
| `extract` | Extract structured data from text |
| `classify` | Classify into predefined categories |
| `fix_grammar` | Correct grammar/spelling errors |
| `sentiment` | Analyze sentiment with confidence |
| `key_points` | Extract main points |
| `rewrite` | Transform tone and style |
| `answer` | Answer questions about text |
| `detect_language` | Identify text language |
| `generate_tags` | Generate relevant tags |
| `anonymize` | Remove/mask PII |
| `compare` | Compare two texts |

## Development

### Running Tests

```bash
bundle exec rake test    # Run all tests
bundle exec rake rubocop # Run linter
bundle exec rake         # Run both
```

### Test Pattern

Tests use Minitest with Mocha for mocking. Each operation has a corresponding `test/ruby_llm/text/[operation]_test.rb` file. Tests mock the LLM responses using:

```ruby
mock_chat = mock("chat")
mock_response = mock("response")
RubyLLM.expects(:chat).returns(mock_chat)
mock_chat.stubs(:with_temperature).returns(mock_chat)
mock_chat.expects(:ask).returns(mock_response)
mock_response.expects(:content).returns("mocked response")
```

### Adding a New Operation

1. Create `lib/ruby_llm/text/[operation].rb` following the operation pattern
2. Add `require_relative "text/[operation]"` to `lib/ruby_llm/text.rb`
3. Add module method in `RubyLLM::Text` class methods section
4. Add tests in `test/ruby_llm/text/[operation]_test.rb`
5. Update `lib/ruby_llm/text/string_ext.rb` if String extension desired
6. Document in README.md

### Configuration

Operations can be configured globally or per-call:

```ruby
# Global configuration
RubyLLM::Text.configure do |config|
  config.temperature = 0.3
  config.summarize_model = "gpt-4.1-mini"
end

# Per-call override
RubyLLM::Text.summarize(text, model: "claude-sonnet-4-5")
```

## Code Style

- Follow rubocop-rails-omakase conventions
- Keep operations focused and single-purpose
- Use keyword arguments for options
- Validate inputs early with helpful error messages
- Return clean data (strings, hashes, arrays) - not raw LLM response objects
