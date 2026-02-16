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
end
