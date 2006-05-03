$LOAD_PATH.unshift("../lib/")
require 'spec'
require 'wackoformatter'

tests = YAML::load("expect.yml")

context "Initial test" do 
end

context "Transformations" do
    tests.each do |test|
	specify test.text do
	    test.source.to_html.should.equal test.expect
	end
    end
end
