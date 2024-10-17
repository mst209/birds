require 'rails_helper'

RSpec.describe Bird do
  before do
    Node.create!(id: 7, parent_id: 6)
    Node.create!(id: 6, parent_id: nil)
    Node.create!(id: 2, parent_id: 7)
    Node.create!(id: 4, parent_id: 7)
    Node.create!(id: 5, parent_id: 4)
  end

  describe 'initalization' do
    it 'a bird can be created' do
      expect { described_class.create!(id: 5, node_id: 7) }.not_to raise_error
    end
  end
end
