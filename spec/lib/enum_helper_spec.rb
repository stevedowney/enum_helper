require File.dirname(__FILE__) + '/../spec_helper'

describe EnumHelper do
  before(:all) do
    module Mod; end
  end

  before(:each) do
    Mod.send(:remove_const, "Klass") rescue nil
    module Mod; class Klass; include EnumHelper; attr_accessor :gender; end; end
    @klass = Mod::Klass
  end
  
  it "default" do
    @klass.enum_helper(:gender, %w(male female))
    
    @klass::GENDERS.should == %w(male female)
    @klass::GENDER_MALE.should == 'male'
    @klass::GENDER_FEMALE.should == 'female'
    
    @male = @klass.new; @male.gender = 'male'
    @male.gender_male?.should be_true
    @male.not_gender_male?.should be_false
    @male.gender_female?.should be_false
    @male.not_gender_female?.should be_true
  end
  
  it "prefix" do
    @klass.enum_helper(:gender, %w(male female), :prefix => 'sex')
    
    @klass::SEXES.should == %w(male female)
    @klass::SEX_MALE.should == 'male'
    @klass::SEX_FEMALE.should == 'female'
    
    @male = @klass.new; @male.gender = 'male'
    @male.sex_male?.should be_true
    @male.not_sex_male?.should be_false
    @male.sex_female?.should be_false
    @male.not_sex_female?.should be_true
  end
  
  it "no prefix" do
    @klass.enum_helper(:gender, %w(male female), :prefix => :none)

    @klass::GENDERS.should == %w(male female)
    @klass::MALE.should == 'male'
    @klass::FEMALE.should == 'female'
    
    @male = @klass.new; @male.gender = 'male'
    @male.male?.should be_true
    @male.not_male?.should be_false
    @male.female?.should be_false
    @male.not_female?.should be_true
  end
  
  it "additional methods" do
    @klass.enum_helper(:gender, %w(male female unknown), :prefix => :none) do |e|
      e.known? %w(male female)
    end
    
    @male = @klass.new; @male.gender = 'male'
    @male.known?.should be_true
    @male.not_known?.should be_false
    
    @unknown = @klass.new; @male.gender = 'unknown'
    @unknown.known?.should be_false
    @unknown.not_known?.should be_true
  end
  
end