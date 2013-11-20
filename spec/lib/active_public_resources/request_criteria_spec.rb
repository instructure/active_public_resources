require 'spec_helper'

describe ActivePublicResources::RequestCriteria do

  it "should set attrs as values on initialize" do
    @request_criteria = ActivePublicResources::RequestCriteria.new({
      :query => "education",
      :page => 3,
      :per_page => 15,
      :sort => "relevance",
      :content_filter => "strict"
    })
    @request_criteria.query.should eq("education")
    @request_criteria.page.should eq(3)
    @request_criteria.per_page.should eq(15)
    @request_criteria.sort.should eq("relevance")
    @request_criteria.content_filter.should eq("strict")
  end

  describe "#validate_options" do
    before :each do
      @request_criteria = ActivePublicResources::RequestCriteria.new
    end

    it "should raise error when options are not present" do
      expect {
        @request_criteria.validate_presence!([:query])
      }.to raise_error(ArgumentError)
    end

    it "should not raise error when options are present" do
      @request_criteria.query = "education"
      expect {
        @request_criteria.validate_presence!([:query])
      }.to_not raise_error
    end
  end

end