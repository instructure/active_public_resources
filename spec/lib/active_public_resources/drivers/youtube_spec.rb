require 'spec_helper'
require 'webmock/rspec'

WebMock.disable_net_connect!

describe APR::Drivers::Youtube do

  let(:driver) { APR::Drivers::Youtube.new }

  describe "#perform_request" do
    it "should raise error when perform_request method is called without a query" do
      expect {
        driver.perform_request(APR::RequestCriteria.new)
      }.to raise_error(StandardError, "You must specify at least a query or channel")
    end

    it "should perform request" do
      stub_request(:get, "https://www.googleapis.com/youtube/v3/search?key=AIzaSyC-PDO3YHSXgfYkng3JjWp5G_HeNgJxkKM&maxResults=25&order=relevance&part=snippet&q=education&safeSearch=strict&type=video").
        to_return(body: File.read('./active_public_resources/spec/lib/fixtures/youtube/education_search.json'), status: 200)
      stub_request(:get, "https://www.googleapis.com/youtube/v3/videos?id=N6oIhdTzx9Q,HndV87XpkWg,S294zRodS_4,BnC6IABJXOI,xhN5Zkm82DA,8ZV_i37wxX8,nA1Aqp0sPQo,7CBKCG7HXjI,DdNAUJWJN08,imHfNDpBlCE,iG9CE55wbtY,_aB9Tg6SRA0,2lmv6ZDm0vw,nHHFGo161Os,Dvhuesh0D5s,Ky7H4CGPbvY,y_ZmM7zPLyI,CWmCrQVFujk,Cv6f-2Wlsxg,tOnDiuL2JmQ,qn9IMe5jmf0,dqTTojTija8,MhS6oqwwOhw,35VgsgICsjo,aV6w-zoacYk&key=AIzaSyC-PDO3YHSXgfYkng3JjWp5G_HeNgJxkKM&part=snippet,contentDetails,statistics").
        to_return(body: File.read('./active_public_resources/spec/lib/fixtures/youtube/education_details_search.json'), status: 200)
      search_criteria = APR::RequestCriteria.new({:query => "education"})
      results = driver.perform_request(search_criteria)
      next_criteria = results.next_criteria
      next_criteria.page.should eq('CBkQAA')
      next_criteria.per_page.should eq(25)
      results.total_items.should eq(1000000)
      results.items.length.should eq(25)

      item = results.items.first
      item.kind.should eq("video")
      item.title.should eq("10 Ways to Get a Better EDUCATION")
      item.description.should match /10 Ways to Get a Better EDUCATION/
      item.thumbnail_url.should eq("https://i.ytimg.com/vi/N6oIhdTzx9Q/default.jpg")
      item.url.should eq("https://www.youtube-nocookie.com/embed/N6oIhdTzx9Q?feature=oembed&rel=0")
      item.duration.should eq(607.0)
      item.num_views.should eq(22650)
      item.num_likes.should eq(1576)
      item.num_comments.should eq(175)
      item.created_date.strftime("%Y-%m-%d").should eq("2020-04-28")
      item.username.should eq("Alux.com")
      item.return_types.count.should eq(1)

      rt_iframe = item.return_types[0]
      rt_iframe.driver.should eq(APR::Drivers::Youtube::DRIVER_NAME)
      rt_iframe.remote_id.should eq("N6oIhdTzx9Q")
      rt_iframe.return_type.should eq('iframe')
      rt_iframe.url.should eq("https://www.youtube-nocookie.com/embed/N6oIhdTzx9Q?feature=oembed&rel=0")

      item.width.should eq(640)
      item.height.should eq(360)
    end
  end
  
end
