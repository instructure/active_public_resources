require 'net/https'
require 'iso8601'

module ActivePublicResources
  module Drivers
    class Youtube < Driver

      DRIVER_NAME = "youtube"
      API_KEY = ENV['YOUTUBE_API_KEY']

      def initialize(config_options={})
        @default_request_criteria = {}
        if config_options[:default_request_criteria]
          @default_request_criteria = config_options[:default_request_criteria]
        end
      end

      def perform_request(request_criteria)
        request_criteria.set_default_criteria!(@default_request_criteria)
        unless request_criteria.validate_presence(:query) || request_criteria.validate_presence(:channel)
          raise ArgumentError "you must specify at least a query or a channel"
        end

        uri = URI('https://www.googleapis.com/youtube/v3/search')
        params = {
          'q' => request_criteria.query,
          'part' => 'snippet',
          'type' => 'video',
          'order' => sort(request_criteria.sort),
          'safeSearch' => content_filter(request_criteria.content_filter),
          'maxResults' => request_criteria.per_page || 25,
          'key' => API_KEY
        }

        params['pageToken'] = request_criteria.page if request_criteria.is_a? String
        params['userIp'] = request_criteria.remote_ip if request_criteria.remote_ip
        params['channelId'] = channel_id(request_criteria.channel_name) if channel_id(request_criteria.channel_name)

        uri.query = URI.encode_www_form(params)
        res = Net::HTTP.get_response(uri)
        results = JSON.parse(res.body)
        return video_details(request_criteria, results)
      end

    private

      def channel_id(channel_name)
        # we are getting the name of the channel.
        # we need to figure out its ID
        if channel_name
          uri = URI('https://www.googleapis.com/youtube/v3/search')
          params = {
            'q' => channel_name,
            'part' => 'id',
            'type' => 'channel',
            'key' => API_KEY
          }
          uri.query = URI.encode_www_form(params)
          res = Net::HTTP.get_response(uri)
          results = JSON.parse(res.body)
          return results['items'].first['id']['channelId'] unless results['items'].empty?
        end

        return false
      end


      def video_details(request_criteria, results)
        video_ids = results['items'].map { |item| item['id']['videoId']}
        uri = URI('https://www.googleapis.com/youtube/v3/videos')
        params = { 'part' => 'snippet,contentDetails,statistics', 'id' => video_ids.join(','), 'key' => API_KEY }
        uri.query = URI.encode_www_form(params)
        res = Net::HTTP.get_response(uri)
        videos = JSON.parse(res.body)['items']
        return parse_results(request_criteria, results, videos)
      end

      def sort(val)
        case val
          when APR::RequestCriteria::SORT_RELEVANCE
            'relevance'
          when APR::RequestCriteria::SORT_RECENT
            'date'
          when APR::RequestCriteria::SORT_POPULAR
            'viewCount'
          else
            'relevance'
        end
      end

      def content_filter(val)
        case val
          when APR::RequestCriteria::CONTENT_FILTER_NONE
            'strict'
          when APR::RequestCriteria::CONTENT_FILTER_STRICT
            'strict'
          else
            'strict'
        end
      end

      def parse_results(request_criteria, results, videos)
        @driver_response = DriverResponse.new(
          :criteria      => request_criteria,
          :next_criteria => next_criteria(request_criteria, results),
          :total_items   => results['pageInfo']['totalResults'].to_i,
          :items         => videos.map { |video| parse_video(video) }
        )
      end

      def next_criteria(request_criteria, results)
        if results['nextPageToken']
          return RequestCriteria.new({
            :query    => request_criteria.query,
            :page     => results['nextPageToken'],
            :per_page => results['pageInfo']['resultsPerPage'].to_i
          })
        end
      end



      def parse_video(item)
        video_id = item['id']
        snippet = item['snippet']
        statistics = item['statistics']
        details = item['contentDetails']
        video = APR::ResponseTypes::Video.new
        video.id             = video_id
        video.title          = snippet['title']
        video.description    = snippet['description']
        video.thumbnail_url  = snippet['thumbnails']['default']['url']
        video.url            = "https://www.youtube.com/watch?v=#{video_id}&feature=youtube_gdata_player"
        video.embed_url      = "https://www.youtube.com/embed/#{video_id}?feature=oembed"
        video.duration       = ISO8601::Duration.new(details['duration']).to_seconds
        video.num_views      = statistics['viewCount'] ? statistics['viewCount'].to_i : 0
        video.num_likes      = statistics['likeCount'] ? statistics['likeCount'].to_i : 0
        video.num_comments   = statistics['commentCount'] ? statistics['commentCount'] : 0
        video.created_date   = Date.parse(snippet['publishedAt'])
        video.username       = snippet['channelTitle']
        video.width          = 640
        video.height         = 360

        # Return Types
        video.return_types << APR::ReturnTypes::Url.new(
          :driver => DRIVER_NAME,
          :remote_id => video.id,
          :url   => video.url,
          :text  => video.title,
          :title => video.title
        )
        video.return_types << APR::ReturnTypes::Iframe.new(
          :driver => DRIVER_NAME,
          :remote_id => video.id,
          :url    => video.embed_url,
          :text   => video.title,
          :title  => video.title,
          :width  => 640,
          :height => 360
        )

        video
      end

    end
  end
end
