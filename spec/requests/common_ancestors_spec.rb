require 'rails_helper'

RSpec.describe 'CommonAncestors' do
  before do
    Node.create!(id: 7, parent_id: 6)
    Node.create!(id: 6, parent_id: nil)
    Node.create!(id: 2, parent_id: 7)
    Node.create!(id: 4, parent_id: 7)
    Node.create!(id: 5, parent_id: 4)
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
