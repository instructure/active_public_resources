require 'spec_helper'

describe APR::Client do

  let(:client)   { APR::Client.new(config_data) }
  let(:criteria) { APR::RequestCriteria.new({ :query => "education" }) }

  describe ".initialize" do
    it "requires valid config as initialize params" do
      expect {
        APR::Client.new
      }.to raise_error(ArgumentError, "key/value pair must be provided")
    end

    it "with valid config" do
      client.initialized_drivers.should include :vimeo
    end
  end

  describe "vimeo" do
    it "should perform request", :vcr, :record => :none do
      results = client.perform_request(:vimeo, criteria)
      next_criteria = results.next_criteria
      next_criteria.page.should eq(2)
      next_criteria.per_page.should eq(25)
      results.total_items.should eq(141538)
      results.items.length.should eq(25)
    end
  end

  describe "youtube" do
    it "should perform request", :vcr, :record => :none do
      results = client.perform_request(:youtube, criteria)
      next_criteria = results.next_criteria
      next_criteria.page.should eq(26)
      next_criteria.per_page.should eq(25)
      results.total_items.should eq(1000000)
      results.items.length.should eq(25)
    end
  end

  describe "shooltube" do
    it "should perform request", :vcr, :record => :none do
      results = client.perform_request(:schooltube, criteria)
      next_criteria = results.next_criteria
      next_criteria.page.should eq(2)
      next_criteria.per_page.should eq(25)
      results.items.length.should eq(25)
    end
  end

  describe "khan_academy" do
    it "should traverse folders", :vcr, :record => :none do
      results = client.perform_request(:khan_academy, criteria)
      results.items.length.should eq(14)

      folder = results.items.first
      rc_2 = APR::RequestCriteria.new({ folder: folder.id });
      results_2 = client.perform_request(:khan_academy, rc_2)
      results_2.items.length.should eq(30)
      results_2.items.map(&:kind).uniq.should eq(['video'])
    end
  end

  describe "quizlet" do
    it "should perform request", :vcr, :record => :none do
      results = client.perform_request(:quizlet, criteria)
      next_criteria = results.next_criteria
      next_criteria.page.should eq(2)
      next_criteria.per_page.should eq(25)
      results.items.length.should eq(25)
    end
  end

end