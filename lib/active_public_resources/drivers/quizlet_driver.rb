require 'net/https'

module ActivePublicResources
  module Drivers
    class QuizletDriver < Driver

      def initialize(config_options={})
        validate_options(config_options, [:client_id])
        @client_id = config_options[:client_id]
      end

      def perform_request(request_criteria)
        raise StandardError.new("driver has not been initialized properly") unless @client_id.present?
        request_criteria.validate_presence!([:query])

        uri = URI('https://api.quizlet.com/2.0/search/sets')
        params = {
          'q'         => request_criteria.query,
          'page'      => request_criteria.page     || 1,
          'per_page'  => request_criteria.per_page || 25,
          'client_id' => @client_id
        }
        uri.query = URI.encode_www_form(params)
        res = Net::HTTP.get_response(uri)
        results = JSON.parse(res.body)

        return parse_results(request_criteria, results)
      end

    private

      def parse_results(request_criteria, results)
        @driver_response = DriverResponse.new(
          :criteria      => request_criteria,
          :next_criteria => next_criteria(request_criteria, results),
          :total_items   => results['total_results'],
          :items         => results['sets'].map { |data| parse_quiz(data) }
        )
      end

      def next_criteria(request_criteria, results)
        if results['total_pages'] > results['page']
          return RequestCriteria.new({
            :query    => request_criteria.query,
            :page     => (request_criteria.page || 1) + 1,
            :per_page => (request_criteria.per_page || 25)
          })
        end
      end

      def parse_quiz(data)
        quiz = ActivePublicResources::ResponseTypes::Quiz.new
        quiz.id            = data['id']
        quiz.title         = data['title']
        quiz.description   = data['description']
        quiz.url           = data['url']
        quiz.term_count    = data['term_count']
        quiz.created_date  = Time.at(data['created_date']).to_date
        quiz.has_images    = data['has_images']
        quiz.subjects      = data['subjects']

        # See http://quizlet.com/help/can-i-embed-quizlet-on-my-website
        quiz.embed_html    = "<iframe src=\"https://quizlet.com/#{data['id']}/flashcards/embedv2\" height=\"410\" width=\"100%\" style=\"border:0;\"></iframe>"
        quiz
      end

    end
  end
end
