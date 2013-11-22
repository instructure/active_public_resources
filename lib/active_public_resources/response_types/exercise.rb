module ActivePublicResources
  module ResponseTypes
    class Exercise < BaseResponseType
      attr_accessor :thumbnail_url, :url

      def kind
        'exercise'
      end
    end
  end
end
