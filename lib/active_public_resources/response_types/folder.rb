module ActivePublicResources
  module ResponseTypes
    class Folder < BaseResponseType
      attr_accessor :parent_id, :videos, :exercises, :images

      def initialize
        super
        @kind = 'folder'
        @videos    = []
        @exercises = []
        @images    = []
      end
    end
  end
end
