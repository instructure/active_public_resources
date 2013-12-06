require 'net/https'

module ActivePublicResources
  module Drivers
    class Schooltube < Driver

      def perform_request(request_criteria)
        request_criteria.validate_presence!([:query])
        uri = URI('http://www.schooltube.com/api/v1/video/search/')
        params = {
          'term' => request_criteria.query,
          'orderby' => normalize_request_criteria(request_criteria, 'sort') || '-view_count',
          'offset' => offset(request_criteria.page, request_criteria.per_page),
          'limit' => request_criteria.per_page || 25
        }
        uri.query = URI.encode_www_form(params)
        res = Net::HTTP.get_response(uri)
        results = JSON.parse(res.body)

        return parse_results(request_criteria, results)
      end

    private

      def offset(page, per_page)
        p = page || 1
        pp = per_page || 25
        p * pp - pp
      end

      def normalize_request_criteria(request_criteria, field_name)
        case field_name
          when 'sort'
            case request_criteria.instance_variable_get("@#{field_name}")
              when 'views'
                return '-view_count'
              else
                return '-view_count'
            end
          else
            request_criteria.instance_variable_get("@#{field_name}")
        end
      end

      def parse_results(request_criteria, results)
        @driver_response = DriverResponse.new(
          :criteria      => request_criteria,
          :next_criteria => next_criteria(request_criteria, results),
          :total_items   => nil,
          :items         => results['objects'].map { |data| parse_video(data) }
        )
      end

      def next_criteria(request_criteria, results)
        if results['meta']['has_next']
          return RequestCriteria.new({
            :query    => request_criteria.query,
            :page     => (request_criteria.page || 1) + 1,
            :per_page => results['meta']['limit'].to_i
          })
        end
      end

      def parse_video(data)
        video = ActivePublicResources::ResponseTypes::Video.new
        video.id            = data['vkey']
        video.title         = data['title']
        video.description   = data['description']
        video.thumbnail_url = data['thumbnail_url']
        video.url           = data['short_url']
        video.embed_url     = "//www.schooltube.com/embed/#{data['vkey']}"
        video.duration      = data['duration'] ? data['duration'].to_i : 0
        video.num_views     = data['view_count'] ? data['view_count'].to_i : 0
        video.num_likes     = data['thumbs_up'] ? data['thumbs_up'].to_i : 0
        video.num_comments  = 0
        video.created_date  = Date.parse(data['create_date'])
        video.username      = data['username']
        video.width         = 640
        video.height        = 360

        # Return Types
        video.return_types << APR::ReturnTypes::Url.new(
          :url   => video.url,
          :text  => video.title,
          :title => video.title
        )
        video.return_types << APR::ReturnTypes::Iframe.new(
          :url    => "//www.schooltube.com/embed/#{data['vkey']}",
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
