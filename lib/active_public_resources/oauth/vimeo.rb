require 'httparty'
require 'base64'

module ActivePublicResources
  module OAuth
    class Vimeo
      attr_reader :token

      AUTHORIZE_URL = 'https://api.vimeo.com/oauth/authorize/client'
      VERIFY_URL = 'https://api.vimeo.com/oauth/verify'

      def initialize(consumer_key, consumer_secret)
        @token = Base64.urlsafe_encode64("#{consumer_key}:#{consumer_secret}")
      end

      def get_access_token
        response = HTTParty.post(
          AUTHORIZE_URL,
          body: { grant_type: 'client_credentials' },
          headers: { "Authorization" => "Basic #{@token}" }
        )
        response['access_token']
      end

      def verify_token?(token)
        response = HTTParty.get(
          VERIFY_URL,
          headers: { "Authorization" => "Bearer #{token}" }
        )
        response.code == 200 ? true : false
      end

    end
  end
end
