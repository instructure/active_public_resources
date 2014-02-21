require 'spec_helper'

describe APR::Drivers::Schooltube do

  let(:driver) { APR::Drivers::Schooltube.new }

  describe "#perform_request" do
    it "should raise error when perform_request method is called without a query" do
      expect {
        driver.perform_request(APR::RequestCriteria.new)
      }.to raise_error(StandardError, "must include query")
    end

    it "should perform request", :vcr, :record => :none do
      search_criteria = APR::RequestCriteria.new({:query => "education"})
      results = driver.perform_request(search_criteria)
      next_criteria = results.next_criteria
      next_criteria.page.should eq(2)
      next_criteria.per_page.should eq(25)
      results.items.length.should eq(25)

      item = results.items.first
      item.id.should eq('60f374fdba394a70b4ad')
      item.kind.should eq("video")
      item.title.should eq("Fun - Educational School Trips - Call American Tours & Travel")
      item.description.should match /customizing your next student/
      item.thumbnail_url.should eq("http://schooltube-thumbnails.s3.amazonaws.com/c5/c3/dd/df/9c/f6/c5c3dddf-9cf6-c0e5-db1f-898f89c301e2.jpg")
      item.url.should eq("http://bit.ly/pk3Sxs")
      item.duration.should eq(102)
      item.num_views.should eq(3513)
      item.num_likes.should eq(0)
      item.num_comments.should eq(0)
      item.created_date.strftime("%Y-%m-%d").should eq("2009-11-12")
      item.username.should eq("StudentGroupTravel")

      rt_url = item.return_types[0]
      rt_url.driver.should eq(APR::Drivers::Schooltube::DRIVER_NAME)
      rt_url.remote_id.should eq("60f374fdba394a70b4ad")
      rt_url.return_type.should eq('url')
      rt_url.url.should eq("http://bit.ly/pk3Sxs")
      rt_url.title.should eq("Fun - Educational School Trips - Call American Tours & Travel")

      rt_iframe = item.return_types[1]
      rt_iframe.return_type.should eq('iframe')
      rt_iframe.url.should eq("https://www.schooltube.com/embed/60f374fdba394a70b4ad")
      rt_iframe.driver.should eq(APR::Drivers::Schooltube::DRIVER_NAME)
      rt_iframe.remote_id.should eq("60f374fdba394a70b4ad")
      rt_iframe.title.should eq("Fun - Educational School Trips - Call American Tours & Travel")

      item.width.should eq(640)
      item.height.should eq(360)
    end
  end
  
end
