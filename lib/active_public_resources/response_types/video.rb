module ActivePublicResources
  module ResponseTypes
    class Video < BaseResponseType
      attr_accessor :thumbnail_url, :url, :duration, :width, :height, :username,
                    :num_views, :num_likes, :num_comments, :created_date,
                    :embed_html, :return_types

      def kind
        'video'
      end
    end
  end
end
