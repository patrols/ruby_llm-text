module RubyLLM
  module Text
    class Configuration
      # Method-specific model overrides (optional)
      # If not set, falls back to RubyLLM.config.default_model
      attr_accessor :summarize_model, :translate_model,
                    :extract_model, :classify_model

      # Default temperature for text operations
      attr_accessor :temperature

      def initialize
        @temperature = 0.3
        @summarize_model = nil
        @translate_model = nil
        @extract_model = nil
        @classify_model = nil
      end

      def model_for(method_name)
        instance_variable_get("@#{method_name}_model") || RubyLLM.config.default_model
      end
    end
  end
end
