module RubyLLM
  module Text
    module Validation
      class ValidationError < Error; end

      def self.validate_text!(text, param_name: "text")
        if text.nil?
          raise ValidationError, "#{param_name} cannot be nil"
        end
        unless text.is_a?(String)
          raise ValidationError, "#{param_name} must be a String, got #{text.class}"
        end
        if text.strip.empty?
          raise ValidationError, "#{param_name} cannot be empty"
        end
      end

      def self.validate_required!(value, param_name)
        if value.nil?
          raise ValidationError, "#{param_name} is required"
        end
      end

      def self.validate_array!(value, param_name, min_size: 1)
        validate_required!(value, param_name)
        unless value.is_a?(Array)
          raise ValidationError, "#{param_name} must be an Array, got #{value.class}"
        end
        if value.size < min_size
          raise ValidationError, "#{param_name} must have at least #{min_size} element(s)"
        end
      end

      def self.validate_one_of!(options, names)
        if options.values.all?(&:nil?)
          raise ValidationError, "must specify at least one of: #{names.join(', ')}"
        end
      end
    end
  end
end
