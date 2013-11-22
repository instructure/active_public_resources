module ActivePublicResources
  module Drivers
    class Driver
      
      def perform_request(*args)
        raise NotImplementedError.new("You must implement perform_request.")
      end

      protected

      def validate_options(opts, req=[])
        req.each do |k|
          if opts.blank? || opts[k].blank?
            raise ArgumentError.new("must include #{req.join(', ')}, instead received #{opts.inspect}")
          end
        end
      end
      
    end
  end
end
