module EnumHelper #:nodoc:
  
  class Builder #:nodoc:
    attr_accessor :klass, :field, :values, :options

    def initialize(klass, field, values, options)
      @klass, @field, @values, @options = klass, field, values, options
      klass.send(:extend, AdditionalMethods)
    end

    def build
      build_plural_constant
      build_singular_constants
      build_predicate_methods
      build_active_record_validations
    end

    def build_plural_constant
      klass.const_set(plural_constant_name, values)
    end

    def build_singular_constants
      values.each do |value|
        klass.const_set(singular_name(value).upcase, value)
      end
    end

    def build_predicate_methods
      values.each do |value|
        method = "#{singular_name(value)}?".downcase
        check = "#{field} == '#{value}'"
        klass.class_eval <<-END
        def #{method}
          #{check}
        end
        def not_#{method}
          !#{method}
        end
        END
      end
    end

    def build_active_record_validations
      validate_inclusion_of = !options.delete(:skip_validation)
      if validate_inclusion_of && klass.ancestors.map(&:to_s).include?("ActiveRecord::Base")
        validate_options = options.merge(:in => values)
        klass.validates_inclusion_of field, validate_options
      end
    end

    def prefix
      @prefix ||= begin
        option_prefix = options.delete(:prefix) || field.to_s
        (option_prefix == :none) ? '' : option_prefix
      end
    end

    def singular_name(value)
      sanitized_value = value.gsub(/\W/, '_')
      if prefix.blank?
        sanitized_value
      else
        "#{prefix}_#{sanitized_value}"
      end
    end

    def plural_constant_name
      if prefix.blank? || prefix.to_s == field.to_s
        field.to_s.pluralize.upcase
      else
        "#{prefix.to_s.pluralize}".upcase
      end
    end

    def method_missing(method, *args, &block)
      klass.define_enum_method(field, method, *args, &block)
    end

  end

end