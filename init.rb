require File.dirname(__FILE__) + '/lib/enum_helper'
ActiveRecord::Base.class_eval { include EnumHelper }
