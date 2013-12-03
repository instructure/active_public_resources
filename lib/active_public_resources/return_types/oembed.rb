module ActivePublicResources
  module ReturnTypes
    class Oembed < BaseReturnType
      attr_accessor :endpoint

      def return_type
        'oembed'
      end
    end
  end
end
