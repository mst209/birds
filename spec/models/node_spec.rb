# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Node do
  before do
    setup_data
  end

  describe 'self_and_ancestors' do
    it 'handles non reference of 7, and should return 7,6' do
      a = described_class.find(7)
      expect(a.self_and_ancestors.map(&:id)).to contain_exactly(7, 6)
    end

    it 'handles cyclical reference of 10, and should return 9,10,11,12' do
      a = described_class.find(10)
      expect(a.self_and_ancestors.map(&:id)).to contain_exactly(9, 10, 11, 12)
    end
  end

  describe 'self_and_descendants' do
    it 'handles non-cyclical reference of 6, and should return 9,10,11,12' do
      a = described_class.find(6)
      expect(a.self_and_descendants.map(&:id)).to contain_exactly(2, 4, 5, 6, 7, 8)
    end

    it 'handles cyclical reference of 10, and should return 9,10,11,12' do
      a = described_class.find(10)
      expect(a.self_and_descendants.map(&:id)).to contain_exactly(9, 10, 11, 12)
    end
  end

  describe 'lowest_common_ancestor' do
    it 'lowest_common_ancestor of 5 and 2 should return 7' do
      a = described_class.find(5)
      b = described_class.find(2)
      expect(a.lowest_common_ancestor(b).id).to eq(7)
    end

    it 'lowest_common_ancestor of 5 and 6 should return 7' do
      a = described_class.find(5)
      b = described_class.find(6)
      expect(a.lowest_common_ancestor(b).id).to eq(6)
    end

    it 'lowest_common_ancestor of 5 and 4 should return 4' do
      a = described_class.find(5)
      b = described_class.find(4)
      expect(a.lowest_common_ancestor(b).id).to eq(4)
    end

    it 'lowest_common_ancestor of 4 and 4 should return 4' do
      a = described_class.find(4)
      b = described_class.find(4)
      expect(a.lowest_common_ancestor(b).id).to eq(4)
    end

    it 'handles cyclical reference of 9 and 11 should return 9' do
      a = described_class.find(9)
      b = described_class.find(11)
      expect(a.lowest_common_ancestor(b).id).to eq(9)
    end

    it 'handles cyclical reference of 10 and 11 should return 10' do
      a = described_class.find(10)
      b = described_class.find(11)
      expect(a.lowest_common_ancestor(b).id).to eq(10)
    end
  end

  describe 'root' do
    it 'the root of 5 should be 6' do
      a = described_class.find(5)
      expect(a.root.id).to eq(6)
    end

    it 'the root of 4 should be 6' do
      a = described_class.find(4)
      expect(a.root.id).to eq(6)
    end

    it 'the root of 6 should be 6' do
      a = described_class.find(6)
      expect(a.root.id).to eq(6)
    end

    it 'handles cyclical reference for 9 and returns a root of 10' do
      a = described_class.find(9)
      expect(a.root.id).to eq(10)
    end

    it 'handles cyclical reference for 12 and returns a root of 9' do
      a = described_class.find(12)
      expect(a.root.id).to eq(9)
    end

    it 'handles cyclical reference for 10 and returns a root of 11' do
      a = described_class.find(10)
      expect(a.root.id).to eq(11)
    end
  end

  describe 'depth' do
    it 'the depth of 5 should be 4' do
      a = described_class.find(5)
      expect(a.depth).to eq(4)
    end

    it 'the depth of 4 should be 3' do
      a = described_class.find(4)
      expect(a.depth).to eq(3)
    end

    it 'the depth of 7 should be 2' do
      a = described_class.find(7)
      expect(a.depth).to eq(2)
    end

    it 'the depth of 6 should be 1' do
      a = described_class.find(6)
      expect(a.depth).to eq(1)
    end

    it 'handles cyclical reference and returns 4' do
      a = described_class.find(9)
      b = described_class.find(10)
      expect(a.depth).to eq(4)
      expect(b.depth).to eq(4)
    end
  end

  describe 'compare' do
    it 'comparing a value that does not exist should result in nil value' do
      expect(described_class.compare(4, 99)).to eq({ root_id: nil, lowest_common_ancestor: nil, depth: nil })
      expect(described_class.compare(99, 4)).to eq({ root_id: nil, lowest_common_ancestor: nil, depth: nil })
    end

    it 'siblings' do
      expect(described_class.compare(4, 2)).to eq({ root_id: 6, lowest_common_ancestor: 7, depth: 2 })
      expect(described_class.compare(2, 4)).to eq({ root_id: 6, lowest_common_ancestor: 7, depth: 2 })
    end

    it 'parent / child' do
      expect(described_class.compare(4, 5)).to eq({ root_id: 6, lowest_common_ancestor: 4, depth: 3 })
      expect(described_class.compare(5, 4)).to eq({ root_id: 6, lowest_common_ancestor: 4, depth: 3 })
    end

    it 'cyclical / child' do
      expect(described_class.compare(9, 11)).to eq({ root_id: 10, lowest_common_ancestor: 9, depth: 4 })
    end
  end

  describe 'search_birds' do
    it 'returns the bird ids' do
      expect(described_class.search_birds([2, 4])).to eq([101, 102, 103, 105])
    end
  end
end
