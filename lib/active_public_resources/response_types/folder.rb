module ActivePublicResources
  module ResponseTypes
    class Folder < BaseResponseType
      attr_accessor :parent_id

      def initialize
        super
        @kind = 'folder'
      end
    end
  end
end
