module ActivePublicResources
  module ResponseTypes
    class Image < BaseResponseType
      attr_accessor :url, :width, :height

      def initialize
        super
        @kind = 'image'
      end
    end
  end
end
