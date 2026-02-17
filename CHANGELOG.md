# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.2.0] - 2025-02-17

### Added
- **Phase 2 Text Operations** - Five powerful new methods for advanced text processing:
  - `fix_grammar` - Grammar and spelling correction with optional change explanations
  - `sentiment` - Sentiment analysis with confidence scores and custom categories
  - `key_points` - Extract main points from long text with format options (bullets, numbers, sentences)
  - `rewrite` - Transform text tone and style (professional, casual, academic, creative, etc.)
  - `answer` - Question answering against provided text with boolean question detection
- **Enhanced Configuration** - Per-method model configuration for all Phase 2 methods
- **Resilient JSON Parsing** - Robust parsing with fallback mechanisms for varied LLM response formats
- **Extended String Extensions** - All Phase 2 methods available as String monkey-patches
- **Comprehensive Manual Testing** - Updated test script covering all 9 methods with real API calls
- **Complete Documentation** - Comprehensive README with API reference for all methods

### Improved
- **Error Handling** - Graceful fallbacks for JSON parsing failures
- **Test Coverage** - 93 tests with 240 assertions covering all functionality
- **Code Quality** - RuboCop compliant codebase with consistent formatting

### Dependencies
- ruby_llm ~> 1.0 (unchanged)
- Ruby >= 3.2.0 (unchanged)

## [0.1.0] - 2025-02-16

### Added
- Initial release of ruby_llm-text gem
- Core functionality for LLM text operations:
  - `summarize` - Condense text into shorter summaries with configurable length
  - `translate` - Translate text between languages
  - `extract` - Extract structured data from unstructured text using schemas
  - `classify` - Classify text into predefined categories
- Configuration system with per-method model overrides
- String extensions for Rails-like method chaining (optional)
- Integration with ruby_llm ecosystem
- Comprehensive test suite with 100% coverage
- GitHub Actions CI/CD pipeline
- Complete documentation and API reference

### Dependencies
- ruby_llm ~> 1.0 (core dependency)
- Ruby >= 3.2.0

[Unreleased]: https://github.com/patrols/ruby_llm-text/compare/v0.2.0...HEAD
[0.2.0]: https://github.com/patrols/ruby_llm-text/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/patrols/ruby_llm-text/releases/tag/v0.1.0