require 'spec_helper'

describe ActivePublicResources::Drivers::Driver do

  it "should raises NotImplementedError" do
    class ActivePublicResources::Drivers::Foo < ActivePublicResources::Drivers::Driver
    end
    [:perform_request].each do |mthd|
      expect {
        ActivePublicResources::Drivers::Foo.new.send(mthd)
      }.to raise_error(NotImplementedError)
    end
  end

  it "should not raise error when methods are overridden" do
    class ActivePublicResources::Drivers::Foo < ActivePublicResources::Drivers::Driver
      def perform_request(*args); end
    end
    [:perform_request].each do |mthd|
      expect {
        ActivePublicResources::Drivers::Foo.new.send(mthd)
      }.not_to raise_error
    end
  end

  describe "#validate_options" do
    before :each do
      class ActivePublicResources::Drivers::Foo < ActivePublicResources::Drivers::Driver
        def initialize(opts={})
          validate_options(opts, [:a, :b, :c])
        end
      end
    end

    it "should raise error when options are not valid" do
      expect {
        ActivePublicResources::Drivers::Foo.new
      }.to raise_error(ArgumentError)
    end

    it "should not raise error when options are valid" do
      expect {
        ActivePublicResources::Drivers::Foo.new({ a: 'x', b: 'y', c: 'z' })
      }.not_to raise_error
    end
  end

end