require 'spec_helper'

describe ActivePublicResources::Drivers::SchooltubeDriver do

  describe "#perform_request" do
    before :each do
      @driver = ActivePublicResources::Drivers::SchooltubeDriver.new
    end

    it "should raise error when perform_request method is called without a query" do
      expect {
        @driver.perform_request(ActivePublicResources::RequestCriteria.new)
      }.to raise_error(StandardError, "must include query")
    end

    it "should perform request", :vcr do
      search_criteria = ActivePublicResources::RequestCriteria.new({:query => "education"})
      results = @driver.perform_request(search_criteria)
      next_criteria = results.next_criteria
      next_criteria.page.should eq(2)
      next_criteria.per_page.should eq(25)
      results.items.length.should eq(25)

      item = results.items.first
      item.kind.should eq("video")
      item.title.should eq("Fun - Educational School Trips - Call American Tours & Travel")
      item.description.should match /customizing your next student/
      item.thumbnail_url.should eq("http://schooltube-thumbnails.s3.amazonaws.com/c5/c3/dd/df/9c/f6/c5c3dddf-9cf6-c0e5-db1f-898f89c301e2.jpg")
      item.url.should eq("http://bit.ly/pk3Sxs")
      item.duration.should eq(102)
      item.num_views.should eq(3481)
      item.num_likes.should eq(0)
      item.num_comments.should eq(0)
      item.created_date.strftime("%Y-%m-%d").should eq("2009-11-12")
      item.username.should eq("StudentGroupTravel")
      item.embed_html.should eq("<iframe src=\"//www.schooltube.com/embed/60f374fdba394a70b4ad\" width=\"640\" height=\"360\" frameborder=\"0\" webkitallowfullscreen mozallowfullscreen allowfullscreen></iframe>")
      item.width.should eq(640)
      item.height.should eq(360)
    end
  end
  
end