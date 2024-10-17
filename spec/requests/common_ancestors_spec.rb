require 'rails_helper'

RSpec.describe 'CommonAncestors' do
  before do
    setup_data
  end

  let(:blank_response) { { root_id: nil, lowest_common_ancestor: nil, depth: nil } }
  let(:good_response) { { root_id: 6, lowest_common_ancestor: 4, depth: 3 } }

  describe 'GET /nodes/99/common_ancestors/5' do
    it 'returns the correct json' do
      get '/nodes/99/common_ancestors/5'
      expect(response).to have_http_status(:ok)
      expect(response.body).to eq(blank_response.to_json)
    end
  end

  describe 'GET /nodes/4/common_ancestors/5' do
    it 'returns the correct json' do
      get '/nodes/4/common_ancestors/5'
      expect(response).to have_http_status(:ok)
      expect(response.body).to eq(good_response.to_json)
    end
  end
end
