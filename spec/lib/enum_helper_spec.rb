require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

module ActiveRecord
  class Base
    def self.named_scope(*args); end
    def self.validates_inclusion_of(*args); end
    def update_attribute(*args); end
  end
end

class Foo < ActiveRecord::Base
  include EnumHelper
  attr_accessor :sex, :size, :body_color

  enum_helper :sex, ['male', 'female'] do
    BOY 'boy'
    Boys {[SEX_MALE, SEX_BOY]}
    m_word? 'male'
    girl? ['lass', 'female']
    fem? { sex == SEX_FEMALE}
  end
  
  enum_helper :size, %w(small large), :prefix => :none do
    TINY 'tiny'
    slight? ['small', 'tiny']
  end
  
  enum_helper :body_color, %w(red green blue), :prefix => 'color' do
    OCEANIC {[COLOR_GREEN, COLOR_BLUE]}
    starts_with_r? 'red'
  end
  
  enum_helper :pcn, %w(pcn1 pcn2), :plural_constant_name => 'plurals'
end

describe EnumHelper do
  
  describe 'default prefix' do
    before(:each) do
      @male = Foo.new; @male.sex = 'male'
      @female = Foo.new; @female.sex = 'female'
    end
    
    it "plural constant" do
      Foo::SEXES.should == %w(male female)
    end
    
    it "singular constants" do
      Foo::SEX_MALE.should == 'male'
      Foo::SEX_FEMALE.should == 'female'
    end
    
    it "predicate methods" do
      @male.sex_male?.should be_true
      @male.sex_female?.should be_false
    end
    
    it "negative predicate methods" do
      @male.sex_not_male?.should be_false
      @male.sex_not_female?.should be_true
    end
    
    it "set methods" do
      @male.sex_set_male
      @male.sex.should == 'male'
      @male.sex_set_female
      @male.sex.should == 'female'
    end
    
    it "set! methods" do
      @male.should_receive(:update_attribute).with(:sex, 'male')
      @male.sex_set_male!
      @male.should_receive(:update_attribute).with(:sex, 'female')
      @male.sex_set_female!
    end
    
    it "constant" do
      Foo::SEX_BOY.should == 'boy'
    end
    
    it "constant w/block" do
      Foo::SEX_Boys.should == %w(male boy)
    end
    
    it "method w/scalar" do
      @male.sex_m_word?.should be_true
      @female.sex_m_word?.should be_false
    end
    
    it "method w/array" do
      @male.sex_girl?.should be_false
      @female.sex_girl?.should be_true
    end
    
    it "method w/block" do
      @male.sex_fem?.should be_false
      @female.sex_fem?.should be_true
    end
  end

  describe 'prefix :none' do
    
    before(:each) do
      @small = Foo.new;@small.size = 'small'
    end
    
    it "not have prefix" do
      Foo::SIZES.should == %w(small large)
      Foo::SMALL.should == 'small'
      @small.small?.should be_true
      @small.not_large?.should be_true
      foo = Foo.new; foo.set_large;foo.size.should == 'large'
      foo.should_receive(:update_attribute).with(:size, 'large')
      foo.set_large!
      Foo::TINY.should == 'tiny'
      @small.slight?.should be_true
    end
  end
  
  describe 'prefix' do
    
    before(:each) do
      @red = Foo.new; @red.body_color = 'red'
    end
    
    it "should use prefix" do
      Foo::COLORS.should == %w(red green blue)
      Foo::COLOR_RED.should == 'red'
      @red.color_red?.should be_true
      @red.color_not_red?.should be_false
      c = Foo.new; c.color_set_blue; c.body_color.should == 'blue'
      c.should_receive(:update_attribute).with(:body_color, 'blue')
      c.color_set_blue!
      Foo::COLOR_OCEANIC.should == %w(green blue)
      @red.color_starts_with_r?.should be_true
    end
  end
  
  describe 'plural constant name' do
    it "should use plural_constant_name" do
      Foo::PLURALS.should == %w(pcn1 pcn2)
    end
  end
  
end