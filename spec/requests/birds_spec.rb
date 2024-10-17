require 'rails_helper'

RSpec.describe 'Birds' do
  before do
    Node.create!(id: 7, parent_id: 6)
    Node.create!(id: 6, parent_id: nil)
    Node.create!(id: 2, parent_id: 7)
    Node.create!(id: 4, parent_id: 7)
    Node.create!(id: 5, parent_id: 4)

    Bird.create!(id: 1, node_id: 5)
    Bird.create!(id: 2, node_id: 2)
    Bird.create!(id: 3, node_id: 4)
    Bird.create!(id: 4, node_id: 7)
    Bird.create!(id: 5, node_id: 7)
  end

  describe 'GET /birds' do
    it 'test' do
      get '/birds?node_ids=2,4'
      expect(response.body).to eq([1, 2, 3].to_json)
      expect(response).to have_http_status(:ok)
    end
  end
end
