require 'net/https'

module ActivePublicResources
  module Drivers
    class Youtube < Driver

      DRIVER_NAME = "youtube"

      def perform_request(request_criteria)
        request_criteria.validate_presence!([:query])

        uri = URI('https://gdata.youtube.com/feeds/api/videos')
        params = {
          'v'           => 2,
          'q'           => request_criteria.query,
          'orderby'     => sort(request_criteria.sort),
          'alt'         => 'json',
          'safeSearch'  => content_filter(request_criteria.content_filter),
          'start-index' => request_criteria.page || 1,
          'max-results' => request_criteria.per_page || 25
        }

        uri.query = URI.encode_www_form(params)

        res = Net::HTTP.get_response(uri)
        results = JSON.parse(res.body)
        
        return parse_results(request_criteria, results)
      end

    private

      def sort(val)
        case val
          when APR::RequestCriteria::SORT_RELEVANCE
            'relevance'
          when APR::RequestCriteria::SORT_RECENT
            'published'
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

      def parse_results(request_criteria, results)
        @driver_response = DriverResponse.new(
          :criteria      => request_criteria,
          :next_criteria => next_criteria(request_criteria, results),
          :total_items   => results['feed']['openSearch$totalResults']['$t'].to_i,
          :items         => results['feed']['entry'].map { |data| parse_video(data) }
        )
      end

      def next_criteria(request_criteria, results)
        start_index = results['feed']['openSearch$startIndex']['$t'].to_i
        per_page    = results['feed']['openSearch$itemsPerPage']['$t'].to_i
        total       = results['feed']['openSearch$totalResults']['$t'].to_i
        if (start_index + per_page) < total
          return RequestCriteria.new({
            :query    => request_criteria.query,
            :page     => start_index + per_page,
            :per_page => per_page
          })
        end
      end

      def parse_video(data)
        video_id = data['id']['$t'].split(':').last
        video = APR::ResponseTypes::Video.new
        video.id            = video_id
        video.title         = data['title']['$t']
        video.description   = data['media$group']['media$description']['$t']
        video.thumbnail_url = data['media$group']['media$thumbnail'][0]['url']
        video.url           = data['media$group']['media$player']['url']
        video.embed_url     = "https://www.youtube.com/embed/#{video_id}?feature=oembed"
        video.duration      = data['media$group']['yt$duration']['seconds'].to_i
        video.num_views     = data['yt$statistics'] ? data['yt$statistics']['viewCount'].to_i : 0
        video.num_likes     = data['yt$rating'] ? data['yt$rating']['numLikes'].to_i : 0
        video.num_comments  = data['gd$comments'] ? data['gd$comments']['gd$feedLink']['countHint'] : 0
        video.created_date  = Date.parse(data['published']['$t'])
        video.username      = data['author'][0]['name']['$t']
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
          :url    => "https://www.youtube.com/embed/#{video_id}?feature=oembed",
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
