module ActivePublicResources
  module ReturnTypes
    class File < BaseReturnType
      attr_accessor :text, :content_type

      def return_type
        'file'
      end
    end
  end
end
