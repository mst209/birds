# frozen_string_literal: true
# typed: strict

class Node < ApplicationRecord

  belongs_to :direct_parent, :class_name => "Node", :foreign_key => :parent_id, :optional => true
  has_many :children, :class_name => "Node", :foreign_key => :parent_id
  has_many :birds

  sig { returns(T::Array[Node]) }
  def self_and_parents
    ([self] + parents).uniq
  end

  sig { returns(T.nilable(Node))}
  def parent
    T.let(direct_parent, T.nilable(Node))
  end

  sig { returns(T::Array[Node]) }
  def parents
    active_node = T.let(self, T.nilable(Node))
    parent_nodes = []
    until active_node.nil?
      break if active_node.parent.nil?

      active_node = active_node.parent
      break if parent_nodes.include?(active_node)

      parent_nodes.push(active_node)
    end
    parent_nodes
  end

  sig{ returns(T::Array[Node]) }
  def self_and_descendants
    ([self] + descendants).uniq
  end

  sig{ params(visited: T::Set[Node]).returns(T::Array[Node]) }
  def descendants(visited = Set.new)
    return [] if visited.include?(self)

    visited.add(self)
    children.each_with_object([]) do |child, arr|
      arr << child
      arr.concat(child.descendants(visited))
    end
  end

  sig{ returns(T.nilable(Node)) }
  def root
    self_and_parents.last
  end

  sig{ returns(Integer) }
  def depth
    self_and_parents.size
  end

  sig{ params(another_node: T.self_type).returns(T.nilable(Node)) }
  def lowest_common_ancestor(another_node)
    return nil if another_node.nil?

    (self_and_parents & another_node.self_and_parents).first
  end

  sig{ params(a_id: Integer, b_id: Integer).returns(T::Hash[Symbol, T.untyped]) }
  def self.compare(a_id, b_id)
    a = Node.find_by(id: a_id)
    b = Node.find_by(id: b_id)

    if !a.nil? && !b.nil?
      lowest_common_ancestor = a.lowest_common_ancestor(b)
      root = a.root
      depth = a.depth
      return { root_id: root.id, lowest_common_ancestor: lowest_common_ancestor.id, depth: depth } unless lowest_common_ancestor.nil? || root.nil? || depth.nil?
    end
    { root_id: nil, lowest_common_ancestor: nil, depth: nil }
  end

  sig{ params(node_ids: T::Array[Integer]).returns(T::Array[Integer]) }
  def self.descendant_ids(node_ids)
    Node.where(id: node_ids).map(&:self_and_descendants).flatten.uniq.map(&:id)
  end

  sig{ params(node_ids: T::Array[Integer]).returns(T::Array[Integer]) }
  def self.search_birds(node_ids)
    Bird.where(node_id: Node.descendant_ids(node_ids)).uniq.map(&:id).sort
  end
end
