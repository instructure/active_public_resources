module ActivePublicResources
  module ReturnTypes
    class Oembed < BaseReturnType
      attr_accessor :endpoint

      def initialize(args)
        super(args.merge(:return_type => 'oembed'))
      end
    end
  end
end
