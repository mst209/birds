# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Node do
  before do
    Node.create!(id: 7, parent_id: 6)
    Node.create!(id: 6, parent_id: nil)
    Node.create!(id: 2, parent_id: 7)
    Node.create!(id: 4, parent_id: 7)
    Node.create!(id: 5, parent_id: 4)
    Node.create!(id: 8, parent_id: 7)
    Node.create!(id: 9, parent_id: 10)
    Node.create!(id: 10, parent_id: 9)
    Node.create!(id: 11, parent_id: 10)
    Node.create!(id: 12, parent_id: 11)
  end

  describe 'self_and_parents' do

    it 'handles non reference of 7, and should return 7,6' do
      a = described_class.find(7)
      expect(a.self_and_parents.map(&:id)).to match_array([7,6])
    end
   
    it 'handles cyclical reference of 10, and should return 9,10,11,12' do
      a = described_class.find(10)
      expect(a.self_and_parents.map(&:id)).to match_array([9,10])
    end
  end

  describe 'self_and_descendants' do

    it 'handles non-cyclical reference of 6, and should return 9,10,11,12' do
      a = described_class.find(6)
      expect(a.self_and_descendants.map(&:id)).to match_array([2,4,5,6,7,8])
    end
   
    it 'handles cyclical reference of 10, and should return 9,10,11,12' do
      a = described_class.find(10)
      expect(a.self_and_descendants.map(&:id)).to match_array([9,10,11,12])
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

    it 'handles cyclical reference and returns a root of 9' do
      a = described_class.find(10)
      expect(a.root.id).to eq(9)
    end

    it 'handles cyclical reference and returns a root of 10' do
      a = described_class.find(9)
      expect(a.root.id).to eq(10)
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

    it 'handles cyclical reference and returns 2' do
      a = described_class.find(9)
      b = described_class.find(10)
      expect(a.depth).to eq(2)
      expect(b.depth).to eq(2)
    end
  end

  describe 'compare' do
    it 'comparing a value that does not exist should result in nil value' do
      expect(described_class.compare(4, 99)).to eq({ root_id: nil, lowest_common_ancestor: nil, depth: nil })
      expect(described_class.compare(99, 4)).to eq({ root_id: nil, lowest_common_ancestor: nil, depth: nil })
    end

    it 'siblings' do
      expect(described_class.compare(4, 2)).to eq({ root_id: 6, lowest_common_ancestor: 7, depth: 3 })
      expect(described_class.compare(2, 4)).to eq({ root_id: 6, lowest_common_ancestor: 7, depth: 3 })
    end

    it 'parent / child' do
      expect(described_class.compare(4, 5)).to eq({ root_id: 6, lowest_common_ancestor: 4, depth: 3 })
      expect(described_class.compare(5, 4)).to eq({ root_id: 6, lowest_common_ancestor: 4, depth: 4 })
    end

    it 'cyclical / child' do
      expect(described_class.compare(9, 11)).to eq({ root_id: 10, lowest_common_ancestor: 9, depth: 2 })
    end
  end
end
