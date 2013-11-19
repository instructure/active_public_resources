require 'spec_helper'

describe ActivePublicResources::Client do

  describe ".initialize" do
    it "requires valid config as initialize params" do
      expect {
        ActivePublicResources::Client.new
      }.to raise_error(ArgumentError, "key/value pair must be provided")
    end

    it "with valid config" do
      config = {
        :vimeo => {
          :consumer_key        => 'CONSUMER_KEY',
          :consumer_secret     => 'CONSUMER_SECRET',
          :access_token        => 'ACCESS_TOKEN',
          :access_token_secret => 'ACCESS_TOKEN_SECRET'
        }
      }
      client = ActivePublicResources::Client.new(config)
      client.initialized_drivers.should eq([:vimeo])
    end
  end

  describe "vimeo" do
    before :each do
      @client = ActivePublicResources::Client.new({
        :vimeo => {
          :consumer_key        => 'CONSUMER_KEY',
          :consumer_secret     => 'CONSUMER_SECRET',
          :access_token        => 'ACCESS_TOKEN',
          :access_token_secret => 'ACCESS_TOKEN_SECRET'
        }
      })
    end

    it "should perform request" do
      # Mock the vimeo response
      json_response = File.read(File.expand_path("../../json_responses/vimeo_1.json", __FILE__))
      OAuth::Consumer.any_instance.stub_chain(:request, :body).and_return(json_response)

      results = @client.search(:vimeo, { query: "education" })
      next_criteria = results.next_criteria
      next_criteria[:page].should eq(2)
      next_criteria[:per_page].should eq(25)
      results.total_items.should eq(140815)
      results.items.length.should eq(25)
    end
  end

end