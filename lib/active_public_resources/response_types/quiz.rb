module ActivePublicResources
  module ResponseTypes
    class Quiz < BaseResponseType
      attr_accessor :url, :term_count, :created_date, :has_images, :subjects,
                    :embed_html

      def kind
        'quiz'
      end
    end
  end
end
