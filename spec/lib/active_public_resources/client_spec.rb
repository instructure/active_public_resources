require 'spec_helper'

describe ActivePublicResources::Client do

  describe ".initialize" do
    it "requires valid config as initialize params" do
      expect {
        ActivePublicResources::Client.new
      }.to raise_error(ArgumentError, "key/value pair must be provided")
    end

    it "with valid config" do
      client = ActivePublicResources::Client.new(config_data)
      client.initialized_drivers.should include :vimeo
    end
  end

  describe "vimeo" do
    before :each do
      @client = ActivePublicResources::Client.new(config_data)
      @request_criteria = ActivePublicResources::RequestCriteria.new({
        :query => "education"
      })
    end

    it "should perform request", :vcr, :record => :new_episodes do
      results = @client.search(:vimeo, @request_criteria)
      next_criteria = results.next_criteria
      next_criteria.page.should eq(2)
      next_criteria.per_page.should eq(25)
      results.total_items.should eq(141538)
      results.items.length.should eq(25)
    end
  end

  describe "youtube" do
    before :each do
      @client = ActivePublicResources::Client.new(config_data)
      @request_criteria = ActivePublicResources::RequestCriteria.new({
        :query => "education"
      })
    end

    it "should perform request", :vcr, :record => :new_episodes do
      results = @client.search(:youtube, @request_criteria)
      next_criteria = results.next_criteria
      next_criteria.page.should eq(2)
      next_criteria.per_page.should eq(25)
      results.total_items.should eq(1000000)
      results.items.length.should eq(25)
    end
  end

  describe "shooltube" do
    before :each do
      @client = ActivePublicResources::Client.new(config_data)
      @request_criteria = ActivePublicResources::RequestCriteria.new({
        :query => "education"
      })
    end

    it "should perform request", :vcr, :record => :new_episodes do
      results = @client.search(:schooltube, @request_criteria)
      next_criteria = results.next_criteria
      next_criteria.page.should eq(2)
      next_criteria.per_page.should eq(25)
      results.items.length.should eq(25)
    end
  end

end