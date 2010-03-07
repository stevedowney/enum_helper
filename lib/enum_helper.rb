dir = File.dirname(__FILE__) + '/enum_helper'
Dir["#{dir}/**/*"].each do |file|
  require file
end

module EnumHelper #:nodoc:
  
  # See the README[link:files/README_rdoc.html] file for complete documentation.
  module ClassMethods
    # call-seq: 
    #   enum_helper(field, values, options = {}, &block)
    #
    # See the README[link:files/README_rdoc.html] file for complete documentation.
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
