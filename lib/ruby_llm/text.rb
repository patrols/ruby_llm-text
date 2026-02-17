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
require_relative "text/key_points"
require_relative "text/rewrite"
require_relative "text/answer"

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

      def key_points(text, **options)
        KeyPoints.call(text, **options)
      end

      def rewrite(text, **options)
        Rewrite.call(text, **options)
      end

      def answer(text, question, **options)
        Answer.call(text, question, **options)
      end
    end
  end
end
