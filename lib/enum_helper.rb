dir = File.dirname(__FILE__) + '/enum_helper'
Dir["#{dir}/**/*"].each { |file| require file }

module EnumHelper #:nodoc:
  
  # See the README[link:files/README_rdoc.html] file for complete documentation.
  module ClassMethods
    # call-seq: 
    #   enum_helper(field, values, options = {}, &block)
    #
    # See the README[link:files/README_rdoc.html] file for complete documentation.
    def enum_helper(field, values, options = {}, &block)
      EnumHelper::Builder.build(self, field, values, options, &block)
    end

  end
  
  def self.included(receiver)
    receiver.extend ClassMethods
  end
  
end
