module ActivePublicResources
  module ReturnTypes
    class File < BaseReturnType
      attr_accessor :text, :content_type

      def initialize(args)
        super(args.merge(:return_type => 'file'))
      end
    end
  end
end
