require 'spec_helper'

describe APR::Drivers::DriverResponse do

  it "should render json" do
    request_criteria = APR::RequestCriteria.new({
      :query          => "education",
      :page           => 1,
      :per_page       => 25,
      :sort           => APR::RequestCriteria::SORT_RELEVANCE,
      :content_filter => APR::RequestCriteria::CONTENT_FILTER_NONE
    })

    next_criteria = APR::RequestCriteria.new({
      :query          => "education",
      :page           => 2,
      :per_page       => 25,
      :sort           => APR::RequestCriteria::SORT_RELEVANCE,
      :content_filter => APR::RequestCriteria::CONTENT_FILTER_NONE
    })

    driver_response = APR::Drivers::DriverResponse.new(
      :criteria      => request_criteria,
      :next_criteria => next_criteria,
      :total_items   => 5500,
      :items         => [ exercise, folder, image, quiz, video ]
    )

    data = JSON.parse(driver_response.to_json)
    data['criteria']['query'].should eq('education')
    data['next_criteria']['page'].should eq(2)
    data['total_items'].should eq(5500)
    data['items'].length.should eq(5)
    data['items'][0]['kind'].should eq('exercise')
    data['items'][0]['title'].should eq(exercise.title)
    data['items'][0]['return_types'][0]['text'].should eq(exercise.title)
    data['items'][1]['kind'].should eq('folder')
    data['items'][1]['title'].should eq(folder.title)
    data['items'][2]['kind'].should eq('image')
    data['items'][2]['title'].should eq(image.title)
    data['items'][3]['kind'].should eq('quiz')
    data['items'][3]['title'].should eq(quiz.title)
    data['items'][3]['return_types'][0]['text'].should eq(quiz.title)
    data['items'][4]['kind'].should eq('video')
    data['items'][4]['title'].should eq(video.title)
    data['items'][4]['return_types'][0]['text'].should eq(video.title)
  end

  private

  def video
    video = APR::ResponseTypes::Video.new
    video.id            = 1
    video.title         = 'Video Title'
    video.description   = 'Lorem ipsum dolor sit amet, consectetur adipisicing elit.'
    video.thumbnail_url = 'http://placekitten.com/50/50.png'
    video.url           = 'http://example.com/videos/1'
    video.duration      = 150
    video.num_views     = 1100
    video.num_likes     = 600
    video.num_comments  = 300
    video.created_date  = Date.today
    video.username      = 'joe'
    video.width         = 640
    video.height        = 360
    video.return_types << APR::ReturnTypes::Url.new({
      :url   => 'http://example.com/videos/1',
      :text  => 'Video Title',
      :title => 'Video Title'
    })
    video.return_types << APR::ReturnTypes::Url.new({
      :url    => "//player.vimeo.com/video/1",
      :text   => 'Video Title',
      :title  => 'Video Title',
      :width  => 640,
      :height => 360
    })
    video
  end

  def folder
    folder = APR::ResponseTypes::Folder.new
    folder.id            = 1
    folder.title         = 'Programming'
    folder.description   = 'Programming videos'
    folder.parent_id     = 'root'
    folder
  end

  def exercise
    exercise = APR::ResponseTypes::Exercise.new
    exercise.id            = 1
    exercise.title         = 'Exercise Title'
    exercise.description   = 'Lorem ipsum dolor sit amet, consectetur adipisicing elit.'
    exercise.thumbnail_url = 'http://placekitten.com/50/50.png'
    exercise.url           = 'http://example.com/exercise/1'
    exercise.return_types << APR::ReturnTypes::Url.new({
      :url => 'http://example.com/exercise/1',
      :text => 'Exercise Title',
      :title => 'Exercise Title'
    })
    exercise
  end

  def image
    image = APR::ResponseTypes::Image.new
    image.id          = 1
    image.title       = 'Image Title'
    image.description = 'Lorem ipsum dolor sit amet, consectetur adipisicing elit.'
    image.url         = 'http://placekitten.com/50/50.png'
    image.width       = 50
    image.height      = 50
    image
  end

  def quiz
    quiz = APR::ResponseTypes::Quiz.new
    quiz.id          = 1
    quiz.title       = 'Quiz Title'
    quiz.description = 'Lorem ipsum dolor sit amet, consectetur adipisicing elit.'
    quiz.url         = 'http://placekitten.com/50/50.png'
    quiz.return_types << APR::ReturnTypes::Url.new({
      :url => 'http://placekitten.com/50/50.png',
      :text => "Quiz Title",
      :title => "Quiz Title"
    })
    quiz.return_types << APR::ReturnTypes::Url.new({
      :url    => "https://quizlet.com/1/flashcards/embedv2",
      :text   => "Flashcards",
      :title  => "Quiz Title",
      :width  => "100%",
      :height => 410
    })
    quiz.return_types << APR::ReturnTypes::Url.new({
      :url    => "https://quizlet.com/1/scatter/embedv2",
      :text   => "Scatter",
      :title  => "Quiz Title",
      :width  => "100%",
      :height => 410
    })
    quiz.return_types << APR::ReturnTypes::Url.new({
      :url    => "https://quizlet.com/1/spacerace/embedv2",
      :text   => "Space Race",
      :title  => "Quiz Title",
      :width  => "100%",
      :height => 410
    })
    quiz
  end

end