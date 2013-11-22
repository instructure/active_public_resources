require 'spec_helper'

describe ActivePublicResources::Drivers::QuizletDriver do

  describe ".initialize" do
    it "should throw error when intializing without proper config options" do
      expect {
        ActivePublicResources::Drivers::QuizletDriver.new
      }.to raise_error(ArgumentError)
    end
  end

  describe "#perform_request" do
    before :each do
      @driver = ActivePublicResources::Drivers::QuizletDriver.new(config_data[:quizlet])
    end

    it "should raise error when perform_request method is called without a query" do
      expect {
        @driver.perform_request(ActivePublicResources::RequestCriteria.new)
      }.to raise_error(StandardError, "must include query")
    end

    it "should perform request", :vcr, :record => :new_episodes do
      search_criteria = ActivePublicResources::RequestCriteria.new({:query => "dogs"})
      results = @driver.perform_request(search_criteria)

      next_criteria = results.next_criteria
      next_criteria.page.should eq(2)
      next_criteria.per_page.should eq(25)
      results.items.length.should eq(25)

      quiz = results.items.first
      quiz.kind.should eq("quiz")
      quiz.title.should eq("Dogs")
      quiz.description.should eq("DOGS, DOGS, DOGS!!!!!!!!")
      quiz.url.should eq("http://quizlet.com/23752218/dogs-flash-cards/")
      quiz.created_date.strftime("%Y-%m-%d").should eq("2013-05-24")
      quiz.embed_html.should eq("<iframe src=\"https://quizlet.com/23752218/flashcards/embedv2\" height=\"410\" width=\"100%\" style=\"border:0;\"></iframe>")
    end
  end
  
end