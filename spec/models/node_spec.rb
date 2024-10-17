# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Node, type: :model do
  let(:node125) { Node.find(125) }
  let(:node5497637) { Node.find(5_497_637) }
  let(:node2820230) { Node.find(2_820_230) }
  before do
    Node.create!(id: 125, parent_id: 130)
    Node.create!(id: 130, parent_id: nil)
    Node.create!(id: 2_820_230, parent_id: 125)
    Node.create!(id: 4_430_546, parent_id: 125)
    Node.create!(id: 5_497_637, parent_id: 4_430_546)
  end
  describe 'lowest_common_ancestor' do
    it 'compare 5497637 and 2820230 should return 125' do
      a = Node.find(5_497_637)
      b = Node.find(2_820_230)
      expect(Node.lowest_common_ancestor(a, b).id).to eq(125)
    end
    it 'compare 5497637 and 130 should return 125' do
      a = Node.find(5_497_637)
      b = Node.find(130)
      expect(Node.lowest_common_ancestor(a, b).id).to eq(130)
    end
    it 'compare 5497637 and 4430546 should return 4430546' do
      a = Node.find(5_497_637)
      b = Node.find(4_430_546)
      expect(Node.lowest_common_ancestor(a, b).id).to eq(4_430_546)
    end
    it 'compare 9 and 4430546 should return 4430546' do
      a = begin
        Node.find(9)
      rescue StandardError
        nil
      end
      b = Node.find(4_430_546)
      expect(Node.lowest_common_ancestor(a, b)).to eq(nil)
    end
    it 'compare 4430546 and 4430546 should return 4430546' do
      a = Node.find(4_430_546)
      b = Node.find(4_430_546)
      expect(Node.lowest_common_ancestor(a, b).id).to eq(4_430_546)
    end
  end

  describe 'root' do
    it 'the root of 5497637 should be 130' do
      a = Node.find(5_497_637)
      expect(a.root.id).to eq(130)
    end

    it 'the root of 4430546 should be 130' do
      a = Node.find(4_430_546)
      expect(a.root.id).to eq(130)
    end
  end
end
