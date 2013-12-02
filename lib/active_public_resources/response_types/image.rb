module ActivePublicResources
  module ResponseTypes
    class Image < BaseResponseType
      attr_accessor :url, :width, :height

      def kind
        'image'
      end
    end
  end
end
