require 'rails_helper'

RSpec.describe 'routes for BirdsController', type: :routing do
  it 'routes /birds to BirdsController' do
    expect(get('/birds?node_ids=4,5')).to route_to(
      controller: 'birds',
      action: 'index',
      node_ids: '4,5'
    )
  end
end
