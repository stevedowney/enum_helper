require File.dirname(__FILE__) + '/../../spec_helper'

describe EnumHelper::Builder do 
  before(:each) do
    @default = EnumHelper::Builder.new(Object, :status, [], {})
    @has_prefix = EnumHelper::Builder.new(Object, :status, [], :prefix => 'state')
    @no_prefix = EnumHelper::Builder.new(Object, :status, [], :prefix => :none)
  end

  describe "prefix" do

    it "defaults to field" do
      @default.prefix.should == 'status'
    end
    
    it "is settable" do
      @has_prefix.prefix.should == 'state'
    end
    
    it "can be removed" do
      @no_prefix.prefix.should == ''
    end
    
  end

  describe 'singular name' do
    
    it "default prefix" do
      @default.singular_name('foo').should == 'status_foo'
    end
    
    it "prefix" do
      @has_prefix.singular_name('foo').should == 'state_foo'
    end
    
    it "no prefix" do
      @no_prefix.singular_name('foo').should == 'foo'
    end
    
    it "should replace non-word chars with underscore" do
      @no_prefix.singular_name("abc-123%").should == 'abc_123_'
    end
  end

  describe 'plural_constant_name' do
    
    it "default prefix" do
      @default.plural_constant_name.should == 'STATUSES'
    end
    
    it "prefix" do
      @has_prefix.plural_constant_name.should == 'STATES'
    end
    
    it "no prefix" do
      @no_prefix.plural_constant_name.should == 'STATUSES'
    end
    
  end
  
end