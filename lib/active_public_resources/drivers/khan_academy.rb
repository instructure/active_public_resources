require 'net/https'

module ActivePublicResources
  module Drivers
    class KhanAcademy < Driver

      DRIVER_NAME = "khan_academy"
      BASE_URL = "https://www.khanacademy.org/api/v1/"

      def perform_request(request_criteria)
        request_criteria.folder ||= 'root'
        results, videos, exercises = get_folder(request_criteria.folder)
        parse_results(request_criteria, results, videos, exercises)
      end

    private

      def perform_rest_request(path)
        uri = URI( BASE_URL + path )
        res = Net::HTTP.get_response(uri)
        JSON.parse(res.body)
      end

      def get_folder(folder_id)
        results = perform_rest_request("topic/#{folder_id}")
        child_data_types  = results['child_data'].map { |item| item['kind'] }.uniq
        videos = []
        if child_data_types.include? "Video"
          videos = get_videos(folder_id)
        end
        exercises = []
        if child_data_types.include? "Exercise"
          exercises = get_exercises(folder_id)
        end
        [results, videos, exercises]
      end

      def get_videos(folder_id)
        perform_rest_request("topic/#{folder_id}/videos")
      end

      def get_exercises(folder_id)
        perform_rest_request("topic/#{folder_id}/exercises")
      end

      def parse_results(request_criteria, results, videos=[], exercises=[])
        parent_id = parse_parent_id(results['slug'], results['extended_slug'])
        
        driver_response = DriverResponse.new(
          :criteria      => request_criteria,
          :next_criteria => nil,
          :total_items   => results['children'].length
        )

        topics = results['children'].find_all { |item| item['kind'] == 'Topic' }
        topics.each do |topic|
          driver_response.items << parse_folder(topic, parent_id)
        end

        videos.each do |video_data|
          driver_response.items << parse_video(video_data)
        end

        exercises.each do |exercise_data|
          driver_response.items << parse_exercise(exercise_data)
        end

        driver_response
      end

      def parse_folder(data, parent_id)
        folder = ActivePublicResources::ResponseTypes::Folder.new
        folder.id        = data['id']
        folder.title     = data['title']
        folder.parent_id = parent_id
        folder
      end

      def parse_video(data)
        video = ActivePublicResources::ResponseTypes::Video.new
        video.id            = data['readable_id']
        video.title         = data['title']
        video.description   = data['description']
        video.thumbnail_url = data['image_url']
        video.url           = data['url']
        video.embed_url     = "https://www.youtube.com/embed/#{data['youtube_id']}?feature=oembed"
        video.duration      = data['duration'] ? data['duration'].to_i : 0
        video.num_views     = 0
        video.num_likes     = 0
        video.num_comments  = 0
        video.created_date  = data['date_added'].present? ? Date.parse(data['date_added']) : nil
        video.username      = data['author_names'].present? ? data['author_names'].first : ''
        video.width         = 640
        video.height        = 360

        # Return Types
        video.return_types << APR::ReturnTypes::Url.new(
          :driver => DRIVER_NAME,
          :url   => video.url,
          :text  => video.title,
          :title => video.title
        )
        video.return_types << APR::ReturnTypes::Iframe.new(
          :driver => DRIVER_NAME,
          :url    => "https://www.youtube.com/embed/#{data['youtube_id']}?feature=oembed",
          :text   => video.title,
          :title  => video.title,
          :width  => 640,
          :height => 360
        )
        video
      end

      def parse_exercise(data)
        exercise = ActivePublicResources::ResponseTypes::Exercise.new
        exercise.id            = data['global_id']
        exercise.title         = data['display_name']
        exercise.description   = data['description']
        exercise.thumbnail_url = data['image_url_256']
        exercise.url           = data['ka_url']

        exercise.return_types << APR::ReturnTypes::Url.new(
          :driver => DRIVER_NAME,
          :url   => exercise.url,
          :text  => exercise.title,
          :title => exercise.title
        )

        exercise
      end

      def parse_parent_id(slug, extended_slug)
        if extended_slug.present?
          if extended_slug != slug
            parts = extended_slug.split("/")
            parts.pop
            parts.last
          else
            'root'
          end
        else
          nil
        end
      end

    end
  end
end
