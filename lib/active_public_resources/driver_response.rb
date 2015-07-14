module ActivePublicResources
  module Drivers
    class DriverResponse
      include ::ActiveModel::Serializers::JSON

      attr_accessor :items, :criteria, :next_criteria, :total_items

      def initialize(args)
        args.each do |k,v|
          instance_variable_set("@#{k}", v) unless v.nil?
        end
        @items ||= []
      end

      def attributes
        instance_values
      end
    end
  end
end
