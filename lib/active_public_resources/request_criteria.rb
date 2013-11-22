module ActivePublicResources
  class RequestCriteria

    attr_accessor :query, :page, :per_page, :content_filter, :sort, :folder

    def initialize(args={})
      args.each do |k,v|
        instance_variable_set("@#{k}", v) unless v.nil?
      end
    end

    def validate_presence!(attr_names)
      attr_names.each do |k|
        if instance_variable_get("@#{k}").blank?
          raise ArgumentError.new("must include #{attr_names.join(', ')}")
        end
      end
    end
  end
end