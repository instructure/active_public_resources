module ActivePublicResources
  module ReturnTypes
    class BaseReturnType
      include ::ActiveModel::Serialization
      
      attr_accessor :url, :return_type

      def initialize(args)
        args.each do |k,v|
          instance_variable_set("@#{k}", v) unless v.nil?
        end
      end

      def attributes
        instance_values
      end
    end
  end
end