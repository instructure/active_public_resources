module ActivePublicResources
  module ResponseTypes
    class Video < BaseResponseType
      attr_accessor :thumbnail_url, :url, :duration, :width, :height, :username,
                    :num_views, :num_likes, :num_comments, :created_date

      def initialize
        super
        @kind = 'video'
      end
    end
  end
end
