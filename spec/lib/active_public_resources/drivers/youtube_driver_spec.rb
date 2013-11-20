require 'spec_helper'

describe ActivePublicResources::Drivers::VimeoDriver do

  describe "#perform_request" do
    before :each do
      @driver = ActivePublicResources::Drivers::YoutubeDriver.new
    end

    it "should raise error when perform_request method is called without a query" do
      expect {
        @driver.perform_request(ActivePublicResources::RequestCriteria.new)
      }.to raise_error(StandardError, "must include query")
    end

    it "should perform request" do
      VCR.use_cassette('youtube_driver/education', :record => :none) do
        search_criteria = ActivePublicResources::RequestCriteria.new({:query => "education"})
        results = @driver.perform_request(search_criteria)
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
        item.num_views.should eq(4121117)
        item.num_likes.should eq(99111)
        item.num_comments.should eq(17636)
        item.created_date.strftime("%Y-%m-%d").should eq("2012-12-02")
        item.username.should eq("sulibreezy")
        item.embed_html.should eq("<iframe src=\"//www.youtube.com/embed/y_ZmM7zPLyI?feature=oembed\" width=\"640\" height=\"360\" frameborder=\"0\" webkitallowfullscreen mozallowfullscreen allowfullscreen></iframe>")
        item.width.should eq(640)
        item.height.should eq(360)
      end
    end
  end
  
end