require_relative '../oauth/vimeo.rb'
require 'httparty'

module ActivePublicResources
  module Drivers
    class Vimeo < Driver
      attr_reader :client

      DRIVER_NAME = "vimeo"
      DEFAULT_CRITERIA = {
        :page           => 1,
        :per_page       => 25,
        :sort           => 'relevant',
        :content_filter => 'safe'
      }

      # Constructor
      #
      # @param [Hash] config_options the options which the vimeo gem requires
      # @option config_options [String] :consumer_key        Vimeo consumer key (required)
      # @option config_options [String] :consumer_secret     Vimeo consumer secret (required)
      def initialize(config_options={})
        validate_options(config_options, [:consumer_key, :consumer_secret])
        @client = ActivePublicResources::OAuth::Vimeo.new(
          config_options[:consumer_key],
          config_options[:consumer_secret]
        )
        @access_token = @client.get_access_token
      end

      # Perform search request to Vimeo with search criteria
      #
      # @param [Hash] criteria the criteria used to perform the search
      # @option criteria [String]  :query          The query text to search for (required)
      # @option criteria [Integer] :page           The page number
      # @option criteria [Integer] :per_page       The number of items per page
      # @option criteria [String]  :sort           The sort filter
      # @option criteria [String]  :content_filter The content filter of which to apply
      #                                            this is not supported yet - https://developer.vimeo.com/api/docs/spec
      #
      # @example Request
      #   driver = ActivePublicResources::Drivers::Vimeo.new({ .. config options .. })
      #   results = driver.perform_request({ query: 'education' })
      #
      # @example Returns
      #   {
      #     'items': [
      #       {
      #         'kind'          : 'video',
      #         'id'            : '1',
      #         'title'         : '',
      #         'description'   : '',
      #         'thumbnail_url' : '',
      #         'url'           : '',
      #         'duration'      : 150,
      #         'num_views'     : 13,
      #         'num_likes'     : 1,
      #         'num_comments'  : 2,
      #         'created_date'  : '',
      #         'username'      : '',
      #         'embed_html'    : '',
      #         'width'         : 640,
      #         'height'        : 360
      #       },
      #       ...
      #     ],
      #     'meta': {
      #       'nextCriteria': {
      #         'query'          : 'education',
      #         'page'           : 2
      #         'per_page'       : 25
      #         'sort'           : 'relevant'
      #         'content_filter' : 'safe'
      #       }
      #     }
      #   }
      #
      # @return [JSON] the normalized response object
      def perform_request(request_criteria)
        request_criteria.validate_presence!([:query])
        raise StandardError.new("driver has not been initialized properly") unless @client

        results = HTTParty.get('https://api.vimeo.com/videos',
          query: {
            query: request_criteria.query,
            page: request_criteria.page || 1,
            per_page: request_criteria.per_page || 25,
            sort: 'relevant',
            filter: 'content_rating',
            filter_content_rating: 'safe'
          },
          headers: { "Authorization" => "Bearer #{@access_token}" }
        )

        if results.code == 401
          if !@client.verify_token?(@access_token)
            @access_token = @client.get_access_token
            perform_request(request_criteria) if @access_token
          end
        else
          return parse_results(request_criteria, JSON.parse(results))
        end
      end

    private

      def sort(val)
        case val
          when APR::RequestCriteria::SORT_RELEVANCE
            'relevant'
          when APR::RequestCriteria::SORT_RECENT
            'newest'
          when APR::RequestCriteria::SORT_POPULAR
            'most_played'
          else
            'relevant'
        end
      end

      def content_filter(val)
        case val
          when APR::RequestCriteria::CONTENT_FILTER_NONE
            'safe'
          when APR::RequestCriteria::CONTENT_FILTER_STRICT
            'safe'
          else
            'safe'
        end
      end

      def parse_results(request_criteria, results)
        @driver_response = DriverResponse.new(
          :criteria      => request_criteria,
          :next_criteria => next_criteria(request_criteria, results),
          :total_items   => results['total'].to_i,
          :items         => results['data'].map { |data| parse_video(data) }
        )
      end

      def next_criteria(request_criteria, results)
        total = results['total'].to_i
        page = results['page'].to_i
        per_page = results['per_page'].to_i

        if ((page * per_page) < total)
          return RequestCriteria.new({
            :query    => request_criteria.query,
            :page     => page + 1,
            :per_page => per_page
          })
        end
      end

      def parse_video(data)
        video = ActivePublicResources::ResponseTypes::Video.new
        video.id            = "#{data['uri']}".gsub(/[^\d]/, '').to_i
        video.title         = data['name']
        video.description   = data['description'] || "No description found"
        video.thumbnail_url = data['pictures']['sizes'][0]['link']
        video.url           = data['link']
        video.embed_url     = "https://player.vimeo.com/video/#{video.id}"
        video.duration      = data['duration'].to_i
        video.num_views     = data['stats']['plays'].to_i
        video.num_likes     = data['metadata']['connections']['likes']['total'].to_i
        video.num_comments  = data['metadata']['connections']['comments']['total'].to_i
        video.created_date  = Date.parse(data['created_time'])
        video.username      = data['user']['name']
        video.width         = 640
        video.height        = 360

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
          :url    => "https://player.vimeo.com/video/#{video.id}",
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
