# frozen_string_literal: true

class Node < ApplicationRecord
  extend ActsAsTree::TreeView
  acts_as_tree

  has_many :birds

  def parents
    @parents ||= begin
      active_node = self
      parent_nodes = [active_node]
      until active_node.nil?
        active_node = active_node.parent
        break if parent_nodes.include?(active_node) || active_node.nil? # Break on recursion or nil

        parent_nodes.push(active_node)
      end
      parent_nodes
    end
  end

  def root
    parents.last
  end

  def depth
    parents.size
  end

  def lowest_common_ancestor(another_node)
    return nil if another_node.nil?

    (parents & another_node.parents).first
  end

  def self.compare(a_id, b_id)
    a = Node.find_by_id(a_id)
    b = Node.find_by_id(b_id)

    if !a.nil? && !b.nil?
      lowest_common_ancestor = a.lowest_common_ancestor(b)
      root = a.root
      depth = a.depth
      return { root_id: root.id, lowest_common_ancestor: lowest_common_ancestor.id, depth: depth } unless lowest_common_ancestor.nil? || root.nil? || depth.nil?
    end
    { root_id: nil, lowest_common_ancestor: nil, depth: nil }
  end
end
