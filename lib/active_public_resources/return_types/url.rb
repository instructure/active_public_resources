module ActivePublicResources
  module ReturnTypes
    class Url < BaseReturnType
      attr_accessor :text, :title, :target

      def initialize(args)
        super(args.merge(:return_type => 'url'))
      end
    end
  end
end
