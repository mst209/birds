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
end
