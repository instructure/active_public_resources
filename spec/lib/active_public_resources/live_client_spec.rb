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

      results = @client.perform_request(:vimeo, @request_criteria)
      next_criteria = results.next_criteria
      next_criteria.page.should eq(2)
      next_criteria.per_page.should eq(25)
      results.total_items.should > 25
      results.items.length.should eq(25)

      next_results = @client.perform_request(:vimeo, results.next_criteria)
      next_results.next_criteria.page.should eq(3)
      next_results.items.first.id.should_not eq(results.items.first.id)
    end
  end

  describe "Youtube" do
    it "performs initial and subsequent requests" do
      results = nil

      results = @client.perform_request(:youtube, @request_criteria)
      next_criteria = results.next_criteria
      next_criteria.page.should eq(2)
      next_criteria.per_page.should eq(25)
      results.total_items.should > 25
      results.items.length.should eq(25)

      next_results = @client.perform_request(:youtube, results.next_criteria)
      next_results.next_criteria.page.should eq(3)
      next_results.items.first.id.should_not eq(results.items.first.id)
    end
  end

  describe "Schooltube" do
    it "performs initial and subsequent requests" do
      results = nil

      results = @client.perform_request(:schooltube, @request_criteria)
      next_criteria = results.next_criteria
      next_criteria.page.should eq(2)
      next_criteria.per_page.should eq(25)
      results.items.length.should eq(25)

      next_results = @client.perform_request(:schooltube, results.next_criteria)
      next_results.next_criteria.page.should eq(3)
      next_results.items.first.id.should_not eq(results.items.first.id)
    end
  end

  describe "Khan Academy" do
    it "performs initial and subsequent requests" do
      results = nil

      root_folder = @client.perform_request(:khan_academy, @request_criteria)
      root_folder.items.length.should eq(14)
      
      sub_folder = root_folder.items.first
      rc_2 = ActivePublicResources::RequestCriteria.new({ folder: sub_folder.id });
      results_2 = @client.perform_request(:khan_academy, rc_2)
      results_2.items.length.should eq(30)
      results_2.items.map(&:kind).uniq.should eq(['video'])
    end
  end
end