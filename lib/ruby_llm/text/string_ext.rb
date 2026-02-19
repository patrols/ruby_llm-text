# Optional String monkey-patching
class String
  def summarize(**options)
    RubyLLM::Text.summarize(self, **options)
  end

  def translate(**options)
    RubyLLM::Text.translate(self, **options)
  end

  def extract(**options)
    RubyLLM::Text.extract(self, **options)
  end

  def classify(**options)
    RubyLLM::Text.classify(self, **options)
  end

  def fix_grammar(**options)
    RubyLLM::Text.fix_grammar(self, **options)
  end

  def sentiment(**options)
    RubyLLM::Text.sentiment(self, **options)
  end

  def key_points(**options)
    RubyLLM::Text.key_points(self, **options)
  end

  def rewrite(**options)
    RubyLLM::Text.rewrite(self, **options)
  end

  def answer(question, **options)
    RubyLLM::Text.answer(self, question, **options)
  end

  def detect_language(**options)
    RubyLLM::Text.detect_language(self, **options)
  end

  def generate_tags(**options)
    RubyLLM::Text.generate_tags(self, **options)
  end

  def anonymize(**options)
    RubyLLM::Text.anonymize(self, **options)
  end

  def compare(other_text, **options)
    RubyLLM::Text.compare(self, other_text, **options)
  end
end
