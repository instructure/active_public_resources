module ActivePublicResources
  module ReturnTypes
    class Url < BaseReturnType
      attr_accessor :text, :title, :target

      def return_type
        'url'
      end
    end
  end
end
