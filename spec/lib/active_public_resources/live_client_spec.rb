# To run this spec from the command line, use
#   $ rspec --tag live_api

require 'spec_helper'

describe ActivePublicResources::Client, :live_api => true do
  before :all do
    @client = ActivePublicResources::Client.new(config_data)
    @request_criteria = ActivePublicResources::RequestCriteria.new({ :query => "learn" })
  end

  describe "Vimeo" do
    it "performs initial and subsequent requests" do
      results = nil

      results = @client.search(:vimeo, @request_criteria)
      next_criteria = results.next_criteria
      next_criteria.page.should eq(2)
      next_criteria.per_page.should eq(25)
      results.total_items.should > 25
      results.items.length.should eq(25)

      next_results = @client.search(:vimeo, results.next_criteria)
      next_results.next_criteria.page.should eq(3)
      next_results.items.first.id.should_not eq(results.items.first.id)
    end
  end

  describe "Youtube" do
    it "performs initial and subsequent requests" do
      results = nil

      results = @client.search(:youtube, @request_criteria)
      next_criteria = results.next_criteria
      next_criteria.page.should eq(2)
      next_criteria.per_page.should eq(25)
      results.total_items.should > 25
      results.items.length.should eq(25)

      next_results = @client.search(:youtube, results.next_criteria)
      next_results.next_criteria.page.should eq(3)
      next_results.items.first.id.should_not eq(results.items.first.id)
    end
  end

  describe "Schooltube" do
    it "performs initial and subsequent requests" do
      results = nil

      results = @client.search(:schooltube, @request_criteria)
      next_criteria = results.next_criteria
      next_criteria.page.should eq(2)
      next_criteria.per_page.should eq(25)
      results.items.length.should eq(25)

      next_results = @client.search(:schooltube, results.next_criteria)
      next_results.next_criteria.page.should eq(3)
      next_results.items.first.id.should_not eq(results.items.first.id)
    end
  end
end