require 'rails_helper'

describe Analyze, type: :request do
  describe "GET /index" do
    let(:expected_payload) do
      {
        'total_posts'       => 8,
        'maximum_timestamp' => 1659476150,
        'minimum_timestamp' => 1659476144,
        'retweets_p50'      => 0,
        'retweets_p90'      => 50,
        'retweets_p99'      => 50
      }
    end

    before do
      allow_any_instance_of(Analyze).to receive(:sleep)
      allow(Analyze).to receive(:call).and_return(expected_payload)
    end

    it 'returns http success' do
      get '/analysis?duration=10s&dimension=likes'

      aggregate_failures do
        expect(response.body).to eq(expected_payload.to_json)

        expect(response.status).to eq(200)
      end
    end

    it 'returns a bad request error if dimension parameter is invalid' do
      expected_payload = { 'error' => 'invalid_dimension_parameter' }.to_json

      get '/analysis?duration=10s&dimension=wrong-dimension'

      aggregate_failures do
        expect(response.body).to eq(expected_payload)

        expect(response.status).to eq(400)
      end
    end

    it 'returns a bad request error if dimension parameter is invalid' do
      expected_payload = { 'error' => 'invalid_duration_parameter' }.to_json

      get '/analysis?duration=10p&dimension=likes'

      expect(response.body).to eq(expected_payload)

      expect(response.status).to eq(400)
    end
  end
end
