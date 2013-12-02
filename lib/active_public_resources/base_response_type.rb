module ActivePublicResources
  module ResponseTypes
    class BaseResponseType
      attr_accessor :id, :title, :description, :return_types

      def initialize
        @return_types = []
      end
    end
  end
end