module ActivePublicResources
  module ResponseTypes
    class BaseResponseType
      include ::ActiveModel::Serialization

      attr_accessor :id, :title, :description, :return_types, :kind

      def initialize
        @return_types = []
      end

      def attributes
        instance_values
      end
    end
  end
end
