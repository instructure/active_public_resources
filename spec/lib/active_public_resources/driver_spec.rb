require 'spec_helper'

describe APR::Drivers::Driver do

  it "should raises NotImplementedError" do
    class APR::Drivers::Foo < APR::Drivers::Driver
    end
    [:perform_request].each do |mthd|
      expect {
        APR::Drivers::Foo.new.send(mthd)
      }.to raise_error(NotImplementedError)
    end
  end

  it "should not raise error when methods are overridden" do
    class APR::Drivers::Foo < APR::Drivers::Driver
      def perform_request(*args); end
    end
    [:perform_request].each do |mthd|
      expect {
        APR::Drivers::Foo.new.send(mthd)
      }.not_to raise_error
    end
  end

  describe "#validate_options" do
    before :each do
      class APR::Drivers::Foo < APR::Drivers::Driver
        def initialize(opts={})
          validate_options(opts, [:a, :b, :c])
        end
      end
    end

    it "should raise error when options are not valid" do
      expect {
        APR::Drivers::Foo.new
      }.to raise_error(ArgumentError)
    end

    it "should not raise error when options are valid" do
      expect {
        APR::Drivers::Foo.new({ a: 'x', b: 'y', c: 'z' })
      }.not_to raise_error
    end
  end

end