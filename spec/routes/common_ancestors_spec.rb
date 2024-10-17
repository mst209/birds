require 'rails_helper'

RSpec.describe 'routes for CommonAncestors', type: :routing do
  it 'routes /nodes/4/common_ancestors/5 to the CommonAncestorsController' do
    expect(get('/nodes/4/common_ancestors/5')).to route_to(
      controller: 'common_ancestors',
      action: 'show',
      node_id: '4',
      id: '5'
    )
  end
end
