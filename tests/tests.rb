$LOAD_PATH.unshift("../lib/")
require 'rubygems'
require_gem 'rspec'
require 'yaml'
require 'ostruct'
require 'wackoformatter'

def load_tests
  tests = YAML::load_file("expect.yml")
  testlist = []
  tests.each do |test|
    testlist << OpenStruct.new(test)
  end
  testlist
end

tests = load_tests

context "Test suite" do
  setup do
    @wf = WackoFormatter.new
  end

  tests.each do |test|
    specify test.title do
      @wf.to_html(test.input).should == test.output
    end
  end
end
