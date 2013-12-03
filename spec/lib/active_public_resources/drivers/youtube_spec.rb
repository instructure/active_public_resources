require 'spec_helper'

describe APR::Drivers::Youtube do

  let(:driver) { APR::Drivers::Youtube.new }

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
      results.total_items.should eq(1000000)
      results.items.length.should eq(25)

      item = results.items.first
      item.kind.should eq("video")
      item.title.should eq("Why I Hate School But Love Education||Spoken Word")
      item.description.should match /The Latest Spoken Word/
      item.thumbnail_url.should eq("https://i.ytimg.com/vi/y_ZmM7zPLyI/default.jpg")
      item.url.should eq("https://www.youtube.com/watch?v=y_ZmM7zPLyI&feature=youtube_gdata_player")
      item.duration.should eq(368)
      item.num_views.should eq(4228173)
      item.num_likes.should eq(101737)
      item.num_comments.should eq(17837)
      item.created_date.strftime("%Y-%m-%d").should eq("2012-12-02")
      item.username.should eq("sulibreezy")
      item.return_types.count.should eq(2)

      rt_url = item.return_types[0]
      rt_url.return_type.should eq('url')
      rt_url.url.should eq("https://www.youtube.com/watch?v=y_ZmM7zPLyI&feature=youtube_gdata_player")
      rt_url.title.should eq("Why I Hate School But Love Education||Spoken Word")

      rt_iframe = item.return_types[1]
      rt_iframe.return_type.should eq('iframe')
      rt_iframe.url.should eq("//www.youtube.com/embed/y_ZmM7zPLyI?feature=oembed")
      rt_url.title.should eq("Why I Hate School But Love Education||Spoken Word")

      item.width.should eq(640)
      item.height.should eq(360)
    end
  end
  
end