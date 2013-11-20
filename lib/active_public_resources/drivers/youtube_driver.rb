require 'net/https'
require 'pry'

module ActivePublicResources
  module Drivers
    class YoutubeDriver < Driver
      attr_reader :client

      DEFAULT_CRITERIA = {
        :v           => 2,
        :orderby     => 'relevance',
        :alt         => 'json',
        :safeSearch  => 'strict',
        :startindex => 1,
        :maxresults => 25
      }

      def perform_request(request_criteria)
        request_criteria.validate_presence!([:query])

        uri = URI('https://gdata.youtube.com/feeds/api/videos')
        params = {
          'v'           => 2,
          'q'           => request_criteria.query,
          'orderby'     => normalize_request_criteria(request_criteria, 'sort'),
          'alt'         => 'json',
          'safeSearch'  => normalize_request_criteria(request_criteria, 'content_filter') || 'strict',
          'start-index' => request_criteria.page || 1,
          'max-results' => request_criteria.per_page || 25
        }

        uri.query = URI.encode_www_form(params)

        res = Net::HTTP.get_response(uri)
        results = JSON.parse(res.body)
        
        return parse_results(request_criteria, results)
      end

    private

      def normalize_request_criteria(request_criteria, field_name)
        case field_name
          when 'sort'
            case request_criteria.instance_variable_get("@#{field_name}")
              when 'relevant'
                return 'relevance'
              else
                return 'relevance'
            end
          when 'content_filter'
            case request_criteria.instance_variable_get("@#{field_name}")
              when 'safe'
                return 'strict'
              else
                return 'strict'
            end
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
        page     = results['feed']['openSearch$startIndex']['$t'].to_i
        per_page = results['feed']['openSearch$itemsPerPage']['$t'].to_i
        total    = results['feed']['openSearch$totalResults']['$t'].to_i
        if ((page * per_page) < total)
          return RequestCriteria.new({
            :query    => request_criteria.query,
            :page     => page + 1,
            :per_page => per_page
          })
        end
      end

      def parse_video(data)
        video_id = data['id']['$t'].split(':').last

        video = ActivePublicResources::ResponseTypes::Video.new
        video.id            = video_id
        video.title         = data['title']['$t']
        video.description   = data['media$group']['media$description']['$t']
        video.thumbnail_url = data['media$group']['media$thumbnail'][0]['url']
        video.url           = data['media$group']['media$player']['url']
        video.duration      = data['media$group']['yt$duration']['seconds'].to_i
        video.num_views     = data['yt$statistics'] ? data['yt$statistics']['viewCount'].to_i : 0
        video.num_likes     = data['yt$rating'] ? data['yt$rating']['numLikes'].to_i : 0
        video.num_comments  = data['gd$comments'] ? data['gd$comments']['gd$feedLink']['countHint'] : 0
        video.created_date  = Date.parse(data['published']['$t'])
        video.username      = data['author'][0]['name']['$t']
        video.embed_html    = "<iframe src=\"//www.youtube.com/embed/#{video_id}?feature=oembed\"" +
                              " width=\"640\" height=\"360\" frameborder=\"0\"" +
                              " webkitallowfullscreen mozallowfullscreen allowfullscreen></iframe>"
        video.width         = 640
        video.height        = 360

        video
      end

    end
  end
end
