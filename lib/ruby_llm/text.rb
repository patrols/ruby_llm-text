require "ruby_llm"
require_relative "text/version"
require_relative "text/configuration"
require_relative "text/base"
require_relative "text/summarize"
require_relative "text/translate"
require_relative "text/extract"
require_relative "text/classify"
require_relative "text/grammar"
require_relative "text/sentiment"

module RubyLLM
  module Text
    class << self
      def configure(&block)
        config.instance_eval(&block) if block_given?
        config
      end

      def config
        @config ||= Configuration.new
      end

      # Module-style API methods
      def summarize(text, **options)
        Summarize.call(text, **options)
      end

      def translate(text, **options)
        Translate.call(text, **options)
      end

      def extract(text, **options)
        Extract.call(text, **options)
      end

      def classify(text, **options)
        Classify.call(text, **options)
      end

      def fix_grammar(text, **options)
        Grammar.call(text, **options)
      end

      def sentiment(text, **options)
        Sentiment.call(text, **options)
      end
    end
  end
end
