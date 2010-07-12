require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe EnumHelper::Builder do 
  before(:each) do
    @default = EnumHelper::Builder.new(Object, :status, [], {})
    @has_prefix = EnumHelper::Builder.new(Object, :status, [], :prefix => 'state')
    @no_prefix = EnumHelper::Builder.new(Object, :status, [], :prefix => :none)
  end

  describe "constant?" do
    
    it "should return true if argument starts with uppercase" do
      @default.constant?("Abc").should be_true
    end
    
    it "should return false if argument doesn't start w/uppercase" do
      @default.constant?("abc").should be_false
    end
  end
  
  describe "prefix, prefix_" do

    it "defaults to field" do
      @default.prefix.should == 'status'
      @default.prefix_.should == 'status_'
    end
    
    it "is settable" do
      @has_prefix.prefix.should == 'state'
      @has_prefix.prefix_.should == 'state_'
    end
    
    it "can be removed" do
      @no_prefix.prefix.should == ''
      @no_prefix.prefix_.should == ''
    end
    
  end

  describe 'singular_constant_prefix' do
    
    it "default prefix" do
      @default.singular_constant_name('foo').should == 'STATUS_FOO'
    end
    
    it "prefix" do
      @has_prefix.singular_constant_name('foo').should == 'STATE_FOO'
    end
    
    it "no prefix" do
      @no_prefix.singular_constant_name('foo').should == 'FOO'
    end
    
    it "should replace non-word chars with underscore" do
      @no_prefix.singular_constant_name("abc-123%").should == 'ABC_123_'
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

    it "plural constant name" do
      b = EnumHelper::Builder.new(Object, :status, %w(a b), :plural_constant_name => 'Pcn')
      b.plural_constant_name.should == 'PCN'

      b = EnumHelper::Builder.new(Object, :status, %w(a b), :plural_constant_name => :pcn)
      b.plural_constant_name.should == 'PCN'
    end
  end
  
end