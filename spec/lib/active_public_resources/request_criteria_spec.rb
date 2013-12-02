require 'spec_helper'

describe APR::RequestCriteria do

  let(:criteria) { APR::RequestCriteria.new }

  it "should set attrs as values on initialize" do
    @request_criteria = APR::RequestCriteria.new({
      :query          => "education",
      :page           => 3,
      :per_page       => 15,
      :sort           => APR::RequestCriteria::SORT_RELEVANCE,
      :content_filter => APR::RequestCriteria::CONTENT_FILTER_NONE
    })
    @request_criteria.query.should eq("education")
    @request_criteria.page.should eq(3)
    @request_criteria.per_page.should eq(15)
    @request_criteria.sort.should eq(APR::RequestCriteria::SORT_RELEVANCE)
    @request_criteria.content_filter.should eq(APR::RequestCriteria::CONTENT_FILTER_NONE)
  end

  describe "#validate_options" do
    it "should raise error when options are not present" do
      expect {
        criteria.validate_presence!([:query])
      }.to raise_error(ArgumentError)
    end

    it "should not raise error when options are present" do
      criteria.query = "education"
      expect {
        criteria.validate_presence!([:query])
      }.to_not raise_error
    end
  end

  it "should validate sort" do
    expect {
      criteria.sort = "whatever"
    }.to raise_error(ArgumentError, "is invalid. Must be in [relevance, recent, popular]")
    
    expect { criteria.sort = APR::RequestCriteria::SORT_RELEVANCE }.to_not raise_error
  end

  it "should validate sort" do
    expect {
      criteria.content_filter = "whatever"
    }.to raise_error(ArgumentError, "is invalid. Must be in [none, strict]")

    expect { criteria.content_filter = APR::RequestCriteria::CONTENT_FILTER_NONE }.to_not raise_error
  end

end