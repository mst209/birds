# frozen_string_literal: true

class Node < ApplicationRecord

  has_many :birds

  def self_and_ancestors
    # to_do: parameratize inputs 
    Node.joins("join get_ancestors_and_self(#{self.id}) ancestors on nodes.id = ancestors.id").order("ancestors.depth")
  end

  def ancestors
    Node.joins("join get_ancestors(#{self.id}) ancestors on nodes.id = ancestors.id").order("ancestors.depth")
  end

  def self_and_descendants
    Node.joins("join get_descendants_and_self(#{self.id}) ancestors on nodes.id = ancestors.id").order("ancestors.depth")
  end

  def descendants
    Node.joins("join get_descendants(#{self.id}) descendants on nodes.id = descendants.id").order("descendants.depth")
  end

  def root
    self_and_ancestors.last
  end

  def depth
    self_and_ancestors.count
  end

  def common_ancestors(another_node)
    self_and_ancestors.joins("join get_ancestors_and_self(#{another_node.id}) ancestors2 on ancestors.id = ancestors2.id").order("ancestors.depth")
  end

  def lowest_common_ancestor(another_node)
    return nil if another_node.nil?
    common_ancestors(another_node).first
  end

  def self.compare(a_id, b_id)
    a = Node.find_by_id(a_id)
    b = Node.find_by_id(b_id)

    if !a.nil? && !b.nil?
      lowest_common_ancestor = a.lowest_common_ancestor(b)
      return { root_id: lowest_common_ancestor.root.id, lowest_common_ancestor: lowest_common_ancestor.id, depth: lowest_common_ancestor.depth } unless lowest_common_ancestor.nil?
    end
    { root_id: nil, lowest_common_ancestor: nil, depth: nil}
  end

  def self.descendant_ids(node_ids)
    Node.where(id: node_ids).map(&:self_and_descendants).flatten.uniq.map(&:id)
  end

  def self.search_birds(node_ids)
    Bird.where(node_id: Node.descendant_ids(node_ids)).uniq.map(&:id).sort
  end
end
