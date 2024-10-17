require 'rails_helper'

RSpec.describe 'Birds' do
  before do
    setup_data
  end

  describe 'GET /birds' do
    it 'test' do
      get '/birds?node_ids=2,4'
      expect(response.body).to eq([101, 102, 103, 105].to_json)
      expect(response).to have_http_status(:ok)
    end
  end
end
