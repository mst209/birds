require 'rails_helper'

RSpec.describe Bird do
  before do
    setup_data
  end

  describe 'initalization' do
    it 'a bird can be created' do
      expect { described_class.create!(id: 99, node_id: 7) }.not_to raise_error
    end
  end

  describe 'search_by_node_ids' do
    it 'returns the bird ids' do
      binding.pry
      expect(described_class.search_by_node_ids([2, 4])).to eq([101, 102, 103, 105])
    end
  end
end
