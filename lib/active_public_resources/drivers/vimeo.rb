require 'vimeo'

module ActivePublicResources
  module Drivers
    class Vimeo < Driver
      attr_reader :client

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
      # @option config_options [String] :access_token        Vimeo access token (required)
      # @option config_options [String] :access_token_secret Vimeo access token secret (required)
      def initialize(config_options={})
        validate_options(config_options, 
          [:consumer_key, :consumer_secret, :access_token, :access_token_secret])
        
        @client = ::Vimeo::Advanced::Video.new(
          config_options[:consumer_key],
          config_options[:consumer_secret],
          token: config_options[:access_token],
          secret: config_options[:access_token_secret]
        )
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
        
        results = @client.search(request_criteria.query, {
          :page           => request_criteria.page || 1,
          :per_page       => request_criteria.per_page || 25,
          :full_response  => 1,
          :sort           => request_criteria.sort || "relevant",
          :user_id        => nil,
          :content_filter => request_criteria.content_filter || 'safe'
        })

        return parse_results(request_criteria, results)
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
          :total_items   => results['videos']['total'].to_i,
          :items         => results['videos']['video'].map { |data| parse_video(data) }
        )
      end

      def next_criteria(request_criteria, results)
        page     = results['videos']['page'].to_i
        per_page = results['videos']['perpage'].to_i
        total    = results['videos']['total'].to_i
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
        video.id            = data['id']
        video.title         = data['title']
        video.description   = data['description']
        video.thumbnail_url = data['thumbnails']['thumbnail'][0]['_content']
        video.url           = data['urls']['url'][0]['_content']
        video.embed_url     = "https://player.vimeo.com/video/#{data['id']}"
        video.duration      = data['duration'].to_i
        video.num_views     = data['number_of_plays'].to_i
        video.num_likes     = data['number_of_likes'].to_i
        video.num_comments  = data['number_of_comments'].to_i
        video.created_date  = Date.parse(data['upload_date'])
        video.username      = data['owner']['display_name']
        video.width         = 640
        video.height        = 360

        # Return Types
        video.return_types << APR::ReturnTypes::Url.new(
          :url   => video.url,
          :text  => video.title,
          :title => video.title
        )
        video.return_types << APR::ReturnTypes::Iframe.new(
          :url    => "https://player.vimeo.com/video/#{data['id']}",
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
