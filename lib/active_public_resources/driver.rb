module ActivePublicResources
  module Drivers
    class Driver
      
      def perform_request(*args)
        raise NotImplementedError.new("You must implement perform_request.")
      end

      def as_json(*args)
        raise NotImplementedError.new("You must implement as_json.")
      end

      protected

      def validate_options(opts, req=[])
        req.each do |k|
          if opts[k].blank?
            raise ArgumentError.new("must include #{req.join(', ')}")
          end
        end
      end
      
    end
  end
end
