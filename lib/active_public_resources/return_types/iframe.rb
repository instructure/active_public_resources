module ActivePublicResources
  module ReturnTypes
    class Iframe < BaseReturnType
      attr_accessor :title, :width, :height

      def return_type
        'iframe'
      end
    end
  end
end
