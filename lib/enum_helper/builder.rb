module EnumHelper #:nodoc:
  
  # The Builder class handles the generation of constants and methods.
  class Builder #:nodoc:
    attr_accessor :klass, :field, :values, :options, :block

    def initialize(klass, field, values, options, &block)
      self.klass = klass
      self.field = field
      self.values = values
      self.options = options
      self.block = block
    end

    def build
      build_plural_constant
      build_singular_constants
      build_predicate_methods
      build_set_methods
      build_named_scopes
      build_additional_constants_and_methods
      build_active_record_validations
    end

    def build_plural_constant
      klass.const_set(plural_constant_name, values)
    end

    def build_singular_constants
      values.each do |value|
        constant_name = singular_constant_name(value)
        klass.const_set(constant_name, value)
      end
    end

    def build_predicate_methods
      values.each do |value|
        sanitized_value = "#{sanitize(value)}?".downcase
        check = "#{field} == '#{value}'"
        code = <<-END
          def #{prefix_}#{sanitized_value}
            #{check}
          end
          def #{prefix_}not_#{sanitized_value}
            !(#{check})
          end
        END
        klass.class_eval code
      end
    end

    def build_set_methods
      values.each do |value|
        sanitized_value = "#{sanitize(value)}".downcase
        code = <<-END
          def #{prefix_}set_#{sanitized_value}
            self.#{field} = #{value.inspect}
          end
        END
        klass.class_eval code
        if active_record_subclass?
          code = <<-END
            def #{prefix_}set_#{sanitized_value}!
              update_attribute(:#{field}, #{value.inspect})
            end
          END
          klass.class_eval code
        end
      end
    end
    
    def build_named_scopes
      if active_record_subclass?
        values.each do |value|
          sanitized_value = "#{sanitize(value)}".downcase
          klass.send :named_scope, "#{prefix_}#{sanitized_value}".to_sym, :conditions => "#{field} = #{value.inspect}"
          klass.send :named_scope, "#{prefix_}not_#{sanitized_value}".to_sym, :conditions => "#{field} != #{value.inspect} or #{field} is null"
        end
      end
    end
    
    def build_additional_constants_and_methods
      instance_eval(&@block) if @block.present?
    end
    
    def build_active_record_validations
      validate_inclusion_of = !options.delete(:skip_validation)
      if validate_inclusion_of && klass.ancestors.map(&:to_s).include?("ActiveRecord::Base")
        validate_options = options.merge(:in => values)
        klass.validates_inclusion_of field, validate_options
      end
    end

    def active_record_subclass?
      klass.ancestors.map(&:to_s).include?("ActiveRecord::Base")
    end
    
    def constant?(string)
      string[0,1] =~ /[A-Z]/
    end
    
    def prefix
      @prefix ||= begin
        option_prefix = options.delete(:prefix) || field.to_s
        (option_prefix == :none) ? '' : option_prefix
      end
    end
    
    def prefix_
      prefix.blank? ? "" : "#{prefix}_"
    end

    def sanitize(value)
      value.gsub(/\W/, '_')
    end
    
    def plural_constant_name
      @plural_constant_name ||= begin
        pcn = options.delete(:plural_constant_name).to_s
        if pcn.present?
          pcn.upcase
        elsif prefix.blank?
          field.to_s.pluralize.upcase
        else
          "#{prefix.to_s.pluralize}".upcase
        end
      end
    end

    def singular_constant_name(value)
      sanitized_value = sanitize(value)
      "#{prefix_}#{sanitized_value}".upcase
    end

    # This handles the creation of "extra" methods defined in any block
    # passed to enum_helper.
    def method_missing(method, *args, &block)
      if method.to_s[0,1] =~ /[A-Z]/
        constant = "#{prefix_.upcase}#{method}"
        if block_given?
          klass.const_set(constant, klass.class_eval(&block))
        else
          value = (args.size == 1) ? args.first : args
          klass.const_set(constant, value)
        end
      else
        method_name = "#{prefix_}#{method}"
        if block_given?
          klass.send(:define_method, method_name) do
            self.instance_eval &block
          end
        else
          check = "#{args.flatten.inspect}.include?(#{field})"
          klass.class_eval <<-END
            def #{method_name}
              #{check}
            end
          END
        end
      end
      
    end

    class << self
      
      def build(klass, field, values, options, &block)
        builder = new(klass, field, values, options, &block)
        builder.build
        nil
      end
      
    end
  end

end