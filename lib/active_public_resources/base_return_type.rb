module ActivePublicResources
  module ReturnTypes
    class BaseReturnType
      attr_accessor :url

      def initialize(args)
        args.each do |k,v|
          instance_variable_set("@#{k}", v) unless v.nil?
        end
      end

      def return_type
        raise NotImplementedError.new("You must implement return_type.")
      end
    end
  end
end