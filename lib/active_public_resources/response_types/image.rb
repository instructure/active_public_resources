module ActivePublicResources
  module ResponseTypes
    class Image < BaseResponseType
      def kind
        'image'
      end
    end
  end
end
