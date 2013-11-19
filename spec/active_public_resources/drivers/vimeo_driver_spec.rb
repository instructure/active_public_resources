require 'spec_helper'
require 'pry'

describe ActivePublicResources::Drivers::VimeoDriver do
  before :each do
    @config_options = {
      :consumer_key        => 'CONSUMER_KEY',
      :consumer_secret     => 'CONSUMER_SECRET',
      :access_token        => 'ACCESS_TOKEN',
      :access_token_secret => 'ACCESS_TOKEN_SECRET'
    }
  end
  
  describe ".initialize" do
    it "should throw error when intializing without proper config options" do
      expect {
        ActivePublicResources::Drivers::VimeoDriver.new
      }.to raise_error(ArgumentError)
    end

    it "should build a vimeo client on initialize" do
      vimeo_driver = ActivePublicResources::Drivers::VimeoDriver.new(@config_options)
      vimeo_driver.client.should be_an_instance_of(::Vimeo::Advanced::Video)
    end
  end

  describe "#perform_request" do
    before :each do
      @vimeo_driver = ActivePublicResources::Drivers::VimeoDriver.new(@config_options)
    end

    it "should raise error when perform_request method is called without a query" do
      expect {
        @vimeo_driver.perform_request({})
      }.to raise_error(StandardError, "must include query")
    end

    it "should raise error when client has not been set" do
      @vimeo_driver.instance_eval("@client = nil")
      expect {
        @vimeo_driver.perform_request({ query: "education" })
      }.to raise_error(StandardError, "driver has not been initialized properly")
    end

    it "should perform request" do
      # Mock the vimeo response
      json_response = File.read(File.expand_path("../../../json_responses/vimeo_1.json", __FILE__))
      OAuth::Consumer.any_instance.stub_chain(:request, :body).and_return(json_response)

      results = @vimeo_driver.perform_request({ :query => "education" })
      next_criteria = results.next_criteria
      next_criteria[:page].should eq(2)
      next_criteria[:per_page].should eq(25)
      results.total_items.should eq(140815)
      results.items.length.should eq(25)

      item = results.items.first
      item.kind.should eq("video")
      item.title.should eq("F L U X")
      item.description.should match /Plato Art Space/
      item.thumbnail_url.should eq("http://b.vimeocdn.com/ts/319/857/319857212_100.jpg")
      item.url.should eq("http://vimeo.com/15395471")
      item.duration.should eq(285)
      item.num_views.should eq(662529)
      item.num_likes.should eq(13842)
      item.num_comments.should eq(344)
      item.created_date.strftime("%Y-%m-%d").should eq("2010-09-29")
      item.username.should eq("candas sisman")
      item.embed_html.should eq("<iframe src=\"//player.vimeo.com/video/15395471\" width=\"640\" height=\"360\" frameborder=\"0\" webkitallowfullscreen mozallowfullscreen allowfullscreen></iframe>")
      item.width.should eq(640)
      item.height.should eq(360)
    end
  end
  
end