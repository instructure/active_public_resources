module ActivePublicResources
  class RequestCriteria
    include ::ActiveModel::Serialization

    SORTS = [
      SORT_RELEVANCE = 'relevance',
      SORT_RECENT    = 'recent',
      SORT_POPULAR   = 'popular'
    ]

    CONTENT_FILTERS = [
      CONTENT_FILTER_NONE   = 'none',
      CONTENT_FILTER_STRICT = 'strict'
    ]

    attr_accessor :query, :page, :per_page, :content_filter, :sort, :folder, :remote_ip, :channel

    def initialize(args={})
      args.each do |k,v|
        if k.to_s == 'sort' && !SORTS.include?(v)
          raise ArgumentError.new("sort is invalid. Must be in [#{SORTS.join(', ')}]")
        end
        if k.to_s == 'content_filter' && !CONTENT_FILTERS.include?(v)
          raise ArgumentError.new("content_filter is invalid. Must be in [#{CONTENT_FILTERS.join(', ')}]")
        end
        instance_variable_set("@#{k}", v) unless v.nil?
      end
    end

    def sort=(val)
      unless SORTS.include?(val)
        raise ArgumentError.new("is invalid. Must be in [#{SORTS.join(', ')}]")
      end
      @sort = val
    end

    def content_filter=(val)
      unless CONTENT_FILTERS.include?(val)
        raise ArgumentError.new("is invalid. Must be in [#{CONTENT_FILTERS.join(', ')}]")
      end
      @content_filter = val
    end

    def validate_presence(attr_names)
      attr_names.each do |k|
        if instance_variable_get("@#{k}").blank?
          return false
        end
      end
      true
    end

    def validate_presence!(attr_names)
      attr_names.each do |k|
        if instance_variable_get("@#{k}").blank?
          raise ArgumentError.new("must include #{attr_names.join(', ')}")
        end
      end
    end

    def attributes
      instance_values
    end
  end
end
