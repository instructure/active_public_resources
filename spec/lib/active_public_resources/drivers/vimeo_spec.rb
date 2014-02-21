require 'spec_helper'

describe APR::Drivers::Vimeo do

  let(:driver) { APR::Drivers::Vimeo.new(config_data[:vimeo]) }
  
  describe ".initialize" do
    it "should throw error when intializing without proper config options" do
      expect {
        APR::Drivers::Vimeo.new
      }.to raise_error(ArgumentError)
    end

    it "should build a vimeo client on initialize" do
      driver.client.should be_an_instance_of(::Vimeo::Advanced::Video)
    end
  end

  describe "#perform_request" do
    it "should raise error when perform_request method is called without a query" do
      expect {
        driver.perform_request(APR::RequestCriteria.new)
      }.to raise_error(StandardError, "must include query")
    end

    it "should raise error when client has not been set" do
      driver.instance_variable_set("@client", nil)
      search_criteria = APR::RequestCriteria.new({:query => "education"})
      expect {
        driver.perform_request(search_criteria)
      }.to raise_error(StandardError, "driver has not been initialized properly")
    end

    it "should perform request", :vcr, :record => :none do
      search_criteria = APR::RequestCriteria.new({:query => "education"})
      results = driver.perform_request(search_criteria)
      next_criteria = results.next_criteria
      next_criteria.page.should eq(2)
      next_criteria.per_page.should eq(25)
      results.total_items.should eq(145819)
      results.items.length.should eq(25)

      item = results.items.first
      item.kind.should eq("video")
      item.title.should eq("Kynect 'education'")
      item.description.should match /Character Design/
      item.thumbnail_url.should eq("http://b.vimeocdn.com/ts/440/661/440661028_100.jpg")
      item.url.should eq("http://vimeo.com/67741947")
      item.duration.should eq(30)
      item.num_views.should eq(16593)
      item.num_likes.should eq(911)
      item.num_comments.should eq(39)
      item.created_date.strftime("%Y-%m-%d").should eq("2013-06-05")
      item.username.should eq("Jens & Anna")

      rt_url = item.return_types[0]
      rt_url.driver.should eq(APR::Drivers::Vimeo::DRIVER_NAME)
      rt_url.return_type.should eq('url')
      rt_url.url.should eq("http://vimeo.com/67741947")
      rt_url.title.should eq("Kynect 'education'")

      rt_iframe = item.return_types[1]
      rt_iframe.driver.should eq(APR::Drivers::Vimeo::DRIVER_NAME)
      rt_iframe.return_type.should eq('iframe')
      rt_iframe.url.should eq("https://player.vimeo.com/video/67741947")
      rt_url.title.should eq("Kynect 'education'")

      item.width.should eq(640)
      item.height.should eq(360)
    end
  end
  
end
