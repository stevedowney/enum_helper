dir = File.dirname(__FILE__) + '/enum_helper'
Dir["#{dir}/**/*"].each do |file|
  require file
end

module EnumHelper #:nodoc:
  
  module ClassMethods
    # call-seq: 
    #   enum_helpers(field, values, options = {}, &block)
    #
    # See README.
    def enum_helper(field, values, options = {})
      builder = EnumHelper::Builder.new(self, field, values, options)
      builder.build
      yield builder if block_given?
    end

  end
  
  def self.included(receiver)
    receiver.extend ClassMethods
  end
  
end
