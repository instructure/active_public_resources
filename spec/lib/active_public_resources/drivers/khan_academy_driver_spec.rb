require 'spec_helper'

describe ActivePublicResources::Drivers::KhanAcademyDriver do

  describe "#perform_request" do
    before :each do
      @driver = ActivePublicResources::Drivers::KhanAcademyDriver.new
    end

    it "should get root folders", :vcr, :record => :new_episodes do
      search_criteria = ActivePublicResources::RequestCriteria.new
      results = @driver.perform_request(search_criteria)
      results.total_items.should eq(14)
      results.items.length.should eq(14)
      results.next_criteria.should be_nil

      folder = results.items.first
      folder.id.should eq("new-and-noteworthy")
      folder.title.should eq("New and noteworthy")
      folder.parent_id.should be_nil
    end

    it "should get folder: cs", :vcr, :record => :new_episodes do
      search_criteria = ActivePublicResources::RequestCriteria.new(
        { folder: "cs" }
      )
      results = @driver.perform_request(search_criteria)
      results.total_items.should eq(1)
      results.items.length.should eq(1)
      results.next_criteria.should be_nil

      folder = results.items.first
      folder.id.should eq("programming")
      folder.title.should eq("Drawing and animation")
      folder.parent_id.should eq("root")
    end

    it "should get folder: cs/programming", :vcr, :record => :new_episodes do
      search_criteria = ActivePublicResources::RequestCriteria.new(
        { folder: "programming" }
      )
      results = @driver.perform_request(search_criteria)
      results.total_items.should eq(11)
      results.items.length.should eq(11)
      results.next_criteria.should be_nil

      folder = results.items.first
      folder.id.should eq("intro-to-programming")
      folder.title.should eq("Intro to programming")
      folder.parent_id.should eq("cs")
    end

    it "should get folder: science/mcat/society-and-culture/social-structures", :vcr, :record => :new_episodes do
      search_criteria = ActivePublicResources::RequestCriteria.new(
        { folder: "social-structures" }
      )
      results = @driver.perform_request(search_criteria)
      results.total_items.should eq(8)
      results.items.length.should eq(8)
      results.next_criteria.should be_nil

      videos = results.items.find_all { |item| item.kind == "video" }
      videos.length.should be(6)
      video = videos.first
      video.kind.should eq("video")
      video.title.should eq("Institutions")
      video.description.should match /Institutions are structures of society/
      video.thumbnail_url.should eq("https://img.youtube.com/vi/9KR1bad76qg/hqdefault.jpg")
      video.url.should eq("http://www.youtube.com/watch?v=9KR1bad76qg&feature=youtube_gdata_player")
      video.duration.should eq(207)
      video.num_views.should eq(0)
      video.num_likes.should eq(0)
      video.num_comments.should eq(0)
      video.created_date.strftime("%Y-%m-%d").should eq("2013-10-10")
      video.username.should eq("Sydney Brown")
      video.embed_html.should eq("<iframe src=\"//www.youtube.com/embed/9KR1bad76qg?feature=oembed\" width=\"640\" height=\"360\" frameborder=\"0\" webkitallowfullscreen mozallowfullscreen allowfullscreen></iframe>")
      video.width.should eq(640)
      video.height.should eq(360)

      exercises = results.items.find_all { |item| item.kind == "exercise" }
      exercises.length.should be(2)
      exercise = exercises.first
      exercise.kind.should eq("exercise")
      exercise.id.should eq("exd53ad0de")
      exercise.title.should eq("Social structures - Passage 1")
      exercise.thumbnail_url.should eq("https://ka-exercise-screenshots.s3.amazonaws.com/social-structures---passage-1_256.png")
      exercise.url.should eq("http://www.khanacademy.org/exercise/social-structures---passage-1")
    end
  end
  
end