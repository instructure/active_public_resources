module ActivePublicResources
  module ReturnTypes
    class Iframe < BaseReturnType
      attr_accessor :title, :width, :height
      
      def initialize(args)
        super(args.merge(:return_type => 'iframe'))
      end
    end
  end
end
