require 'spec_helper.rb'

describe User do
  it "should run spec test with shoulda and models from application" do
    Guest.new.should_not be_administrator
  end
end
