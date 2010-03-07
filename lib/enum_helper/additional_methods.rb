module EnumHelper #:nodoc:

  module AdditionalMethods #:nodoc:

    def define_enum_method(field, method, *args, &block)
      values = [args.first].flatten
      expr = "#{values.inspect}.include?(#{field})"
      class_eval <<-END
      def #{method}
        #{expr}
      end
      def not_#{method}
        !#{method}
      end
      END
    end

  end

end