dir = File.dirname(__FILE__) + '/enum_helper'
Dir["#{dir}/**/*"].each { |file| require file }

module EnumHelper #:nodoc:
  
  # See the README[link:files/README_rdoc.html] file for complete documentation.
  module ClassMethods
    # Define constants, predicate methods, and more for an enumeration.
    #
    # @param [Symbol] field attribute on which enumeration is defined
    # @param [Array] values set of values constituting the enumeration
    # @param [Hash] options
    # @option options [Boolean] :plural_constant_name (field.to_s.pluralize) name of plural constant
    # @option options [Symbol, String] :prefix (field) prefix for constants and predicate methods
    # @option options [Boolean] :skip_validation (false) set to +true+ to skip +ActiveRecord+ +validates_inclusion_of+ validation
    # @option options [Object] all_others all others are passed to +validates_inclusion_of+
    # @param [Block] &block where various other helper methods and constants can be defined.  See examples.
    # @return [void]
    # 
    # @example Simplest Usage
    #
    #   class Person < ActiveRecord::Base
    #     enum_helper :sex, %w(male female)
    #   end
    # 
    #   # constants
    # 
    #   Person::SEXES       #=> ["male", "female"]
    #   Person::SEX_MALE    #=> "male"
    #   Person::SEX_FEMALE  #=> "female"
    # 
    #   guy = Person.new(:sex => SEX_MALE)  #=> #<Person id: nil, sex: "male">
    # 
    #   # predicate methods
    # 
    #   guy.sex_male?                     #=> true
    #   guy.sex_female?                   #=> false
    # 
    #   # validates_inclusion_of by default
    # 
    #   guy.valid?           #=> true
    #   guy.status = 'foo'
    #   guy.valid?           #=> false
    # 
    # @example Specify a Prefix
    #   
    #  class Person < ActiveRecord::Base
    #    enum_helper :sex, %w(male female), :prefix => 'gender'
    #  end
    #
    #  Person::GENDER_MALE                      #=> "male"
    #  Person.new(:sex => 'male').gender_male?  #=> true
    #
    # @example No Prefix
    #   
    #  class Person < ActiveRecord::Base
    #    enum_helper :sex, %w(male female), :prefix => :none
    #  end
    #
    #  Person::MALE                      #=> "male"
    #  Person.new(:sex => 'male').male?  #=> true
    #
    # @example Plural Consant
    #
    #   # plural constant name defaults to plural of (options[:prefix] || field)
    #   class Person < ActiveRecord::Base
    #     enum_helper :hue, %w(red blue), :plural_constant_name => "COLORS"
    #   end
    # 
    #   Person::COLORS       #=> ["red", "blue"]
    #
    # @example Negated Predicate Methods
    # 
    #   # For every generated method <tt>foo?</tt>, a negated version <tt>not_foo?</tt> is generated:
    # 
    #   class Person < ActiveRecord::Base
    #     enum_helper :sex, %w(male female)
    #   end
    # 
    #   person = Person.new(:sex => 'male')
    # 
    #   person.sex_male?      #=> true
    #   person.sex_not_male?  #=> false
    # 
    # @example Assignment (!) methods
    #
    #   # Each enumerated value has its own assignment method generated:
    # 
    #   class Person < ActiveRecord::Base
    #     enum_helper :sex, %w(male female)
    #   end
    # 
    #   person = Person.new
    # 
    #   person.sex_male!    # same as: person.sex = 'male'
    #   person.sex_female!  # same as: person.sex = 'female'
    #
    # @example Related Methods and Constants
    # 
    #   class Person < ActiveRecord::Base
    # 
    #     enum_helper :sex, %w(boy girl unknown) do
    #       female? 'girl'
    #       KNOWN ['boy', 'girl']
    #     end
    # 
    #     enum_helper :size, ['small', 'medium', 'large', 'extra large'] do
    #       big? ['large', 'extra large']
    #     end
    # 
    #   end
    # 
    #   Person::SEX_KNOWN   #=> ['boy', 'girl']
    # 
    #   person = Person.new(:child => 'girl', :size => 'medium')
    # 
    #   person.sex_female?  #=> true
    #   person.size_big?    #=> false
    #
    # @example Related Methods and Constants with Blocks
    #
    #   # If you want to reference a constant, instance variable, or instance method, pass a block.
    #   # The block is evaluated in the context of the instance so any instance methods, attributes, etc.
    #   # can be referenced.
    # 
    #   class Car < ActiveRecord::Base
    # 
    #     enum_helper :color, %w(red cherry green blue), :prefix => :none do
    #       REDS { [RED, CHERRY] }
    #       reddish? { REDS.include?(color) }
    #       reddish_and_old? { reddish? && age > 20 }
    #     end
    # 
    #   end
    #
    # @example Options for +ActiveRecord::validates_inclusion_of+
    # 
    #   # All options not recognized by enum_helper are passed to validates_inclusion_of.
    # 
    #   class Person < ActiveRecord::Base
    # 
    #     # :allow_blank and :message passed to validates_inclusion_of
    #     enum_helper :gender, %w(male female), :allow_blank => true, :message => 'must be "male" or "female"'
    # 
    #   end
    #
    # @example Skip <tt>validates_inclusion_of</tt> Validation
    # 
    #   class Person < ActiveRecord::Base
    # 
    #     enum_helper :gender, %w(male female), :skip_validation => true
    # 
    #   end
    # 
    # @example Using with non-ActiveRecord Classes
    # 
    #   # Non-ActiveRecord classes need to 'include EnumHelper'.  
    # 
    #   class Team  # not a subclass of ActiveRecord
    #     include EnumHelper
    # 
    #     enum_helper :category, %w(sales engineering management)
    #
    #   end
    # 
    #   ActiveRecord validates_inclusion_of is skipped for non-ActiveRecord
    #   classes regardless of the :skip_validation option.
    # 
    # == Tip
    # 
    # If you are having trouble figuring out what constants and methods are getting generated, try:
    # 
    #   MyClass.constants
    #   MyClass.new.methods
    # 
    # or if too much is returned:
    # 
    #   MyClass.constants.grep(/<search term>/i).sort
    #   MyClass.new.methods.grep(/<search term>/i).sort
    # 
    # 
    #  
    #
    def enum_helper(field, values, options = {}, &block)
      EnumHelper::Builder.build(self, field, values, options, &block)
    end

  end
  
  # @private
  def self.included(receiver)
    receiver.extend ClassMethods
  end
  
end
