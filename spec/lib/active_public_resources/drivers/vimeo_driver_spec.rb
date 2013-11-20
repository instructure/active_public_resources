require 'spec_helper'

describe ActivePublicResources::Drivers::VimeoDriver do
  
  describe ".initialize" do
    it "should throw error when intializing without proper config options" do
      expect {
        ActivePublicResources::Drivers::VimeoDriver.new
      }.to raise_error(ArgumentError)
    end

    it "should build a vimeo client on initialize" do
      driver = ActivePublicResources::Drivers::VimeoDriver.new(config_data[:vimeo])
      driver.client.should be_an_instance_of(::Vimeo::Advanced::Video)
    end
  end

  describe "#perform_request" do
    before :each do
      @driver = ActivePublicResources::Drivers::VimeoDriver.new(config_data[:vimeo])
    end

    it "should raise error when perform_request method is called without a query" do
      expect {
        @driver.perform_request(ActivePublicResources::RequestCriteria.new)
      }.to raise_error(StandardError, "must include query")
    end

    it "should raise error when client has not been set" do
      @driver.instance_variable_set("@client", nil)
      search_criteria = ActivePublicResources::RequestCriteria.new({:query => "education"})
      expect {
        @driver.perform_request(search_criteria)
      }.to raise_error(StandardError, "driver has not been initialized properly")
    end

    it "should perform request", :vcr, :record => :new_episodes do
      search_criteria = ActivePublicResources::RequestCriteria.new({:query => "education"})
      results = @driver.perform_request(search_criteria)
      next_criteria = results.next_criteria
      next_criteria.page.should eq(2)
      next_criteria.per_page.should eq(25)
      results.total_items.should eq(141538)
      results.items.length.should eq(25)

      item = results.items.first
      item.kind.should eq("video")
      item.title.should eq("F L U X")
      item.description.should match /Plato Art Space/
      item.thumbnail_url.should eq("http://b.vimeocdn.com/ts/319/857/319857212_100.jpg")
      item.url.should eq("http://vimeo.com/15395471")
      item.duration.should eq(285)
      item.num_views.should eq(662907)
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