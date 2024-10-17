# frozen_string_literal: true

class Node < ApplicationRecord
  extend ActsAsTree::TreeView
  acts_as_tree

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

  def self.lowest_common_ancestor(a, b)
    return nil if a.nil? || b.nil?

    a_parents = a.parents
    b_parents = b.parents
    (a_parents & b_parents).first
  end

  def self.compare(a, b)
    lowest_common_ancestor = Node.lowest_common_ancestor(a, b)
    return { root_id: null, lowest_common_ancestor: null, depth: null } if lowest_common_ancestor.nil?

    root = a.root
    depth = Node.depth(lowest_common_ancestor, root)
    { root_id: root.id, lowest_common_ancestor: lowest_common_ancestor.id, depth: depth }
  end
end
