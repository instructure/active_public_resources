require 'spec_helper'
require 'base64'
require 'securerandom'

describe APR::OAuth::Vimeo do

  let(:client) { APR::OAuth::Vimeo.new(consumer_key, consumer_secret) }
  let(:consumer_key) { 'key' }
  let(:consumer_secret) { 'secret' }
  let(:token) { Base64.urlsafe_encode64("#{consumer_key}:#{consumer_secret}") }
  let(:access_token) { "#{SecureRandom.uuid}" }

  describe ".initialize" do
    it "should build a base64 encoded token" do
      expect(client.token).to eq token
    end
  end

  describe "#get_access_token" do
    let(:response) { { "access_token" => access_token } }

    it "should generate an access token" do
      allow(HTTParty).to receive(:post) { response }
      expect(client.get_access_token).to eq access_token
    end
  end

  describe "#verify_token?" do
    let(:response_ok) { double(:code => 200) }
    let(:response_unauthorized) { double(:code => 401) }

    it "should return 200 if token is verified" do
      allow(HTTParty).to receive(:get) { response_ok }
      expect(client.verify_token?(token)).to eq true
    end

    it "should return 401 if token is unauthorized" do
      allow(HTTParty).to receive(:get) { response_unauthorized }
      expect(client.verify_token?(token)).to eq false
    end
  end

end
