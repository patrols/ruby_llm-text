# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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

[Unreleased]: https://github.com/patrols/ruby_llm-text/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/patrols/ruby_llm-text/releases/tag/v0.1.0