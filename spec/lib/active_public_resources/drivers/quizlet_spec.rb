require 'spec_helper'

describe APR::Drivers::Quizlet do

  let(:driver) { APR::Drivers::Quizlet.new(config_data[:quizlet]) }

  describe ".initialize" do
    it "should throw error when intializing without proper config options" do
      expect {
        APR::Drivers::Quizlet.new
      }.to raise_error(ArgumentError)
    end
  end

  describe "#perform_request" do
    it "should raise error when perform_request method is called without a query" do
      expect {
        driver.perform_request(APR::RequestCriteria.new)
      }.to raise_error(StandardError, "must include query")
    end

    it "should perform request", :vcr, :record => :none do
      search_criteria = APR::RequestCriteria.new({:query => "dogs"})
      results = driver.perform_request(search_criteria)

      next_criteria = results.next_criteria
      next_criteria.page.should eq(2)
      next_criteria.per_page.should eq(25)
      results.items.length.should eq(25)

      quiz = results.items.first
      quiz.kind.should eq("quiz")
      quiz.title.should eq("Dogs")
      quiz.description.should eq("DOGS, DOGS, DOGS!!!!!!!!")
      quiz.url.should eq("http://quizlet.com/23752218/dogs-flash-cards/")
      quiz.created_date.strftime("%Y-%m-%d").should eq("2013-05-25")

      quiz.return_types[0].driver.should eq(APR::Drivers::Quizlet::DRIVER_NAME)
      quiz.return_types[0].remote_id.should eq(23752218)
      quiz.return_types[0].url.should eq("http://quizlet.com/23752218/dogs-flash-cards/")
    end
  end
  
end
