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

  def depth
    parents.size
  end

  def lowest_common_ancestor(b)
    return nil if b.nil?

    (parents & b.parents).first
  end

  def self.compare(a_id, b_id)
    a = begin
      Node.find(a_id)
    rescue StandardError
      nil
    end
    b = begin
      Node.find(b_id)
    rescue StandardError
      nil
    end
    if !a.nil? && !b.nil?
      lowest_common_ancestor = a.lowest_common_ancestor(b)
      unless lowest_common_ancestor.nil?
        root = a.root
        unless root.nil?
          depth = a.depth
          return { root_id: root.id, lowest_common_ancestor: lowest_common_ancestor.id, depth: depth } unless depth.nil?
        end
      end
    end
    { root_id: nil, lowest_common_ancestor: nil, depth: nil }
  end
end
