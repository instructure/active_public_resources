module ActivePublicResources
  module ReturnTypes
    class ImageUrl < BaseReturnType
      attr_accessor :text, :width, :height

      def return_type
        'image_url'
      end
    end
  end
end
