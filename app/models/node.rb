# frozen_string_literal: true

class Node < ApplicationRecord
  has_many :birds

  def self_and_ancestors
    # to_do: parameratize inputs
    Node.with(
      :recursive,
      node_ancestors: "
      SELECT n1.id, n1.parent_id, 0 AS depth, ARRAY[n1.id] AS path
      FROM nodes n1
      WHERE n1.id = #{id}

      UNION ALL

      SELECT t.id, t.parent_id, ta.depth + 1, ta.path || t.id
      FROM nodes t
      INNER JOIN node_ancestors ta ON t.id = ta.parent_id
      WHERE NOT t.id = ANY(ta.path)
    "
    ).joins('JOIN node_ancestors na ON nodes.id = na.id').order('na.depth')
  end

  def ancestors
    self_and_ancestors.where('nodes.id != na.id').order('na.depth')
  end

  def self_and_descendants
    Node.with(
      :recursive,
      node_descendants: "
      SELECT n1.id, n1.parent_id, 0 AS depth, ARRAY[n1.id] AS path
      FROM nodes n1
      WHERE n1.id = #{id}

      UNION ALL

      SELECT t.id, t.parent_id, td.depth + 1, td.path || t.id
      FROM nodes t
      INNER JOIN node_descendants td ON t.parent_id = td.id
      WHERE NOT t.id = ANY(td.path)
    "
    ).joins('JOIN node_descendants nd ON nodes.id = nd.id').order('nd.depth')
  end

  def descendants
    self_and_descendants.joins('JOIN node_descendants nd ON nodes.id = nd.id').where('nodes.id != nd.id').order('nd.depth')
  end

  def root
    self_and_ancestors.last
  end

  def depth
    self_and_ancestors.count
  end

  def common_ancestors(another_node)
    self_and_ancestors.with(
      :recursive,
      another_node_ancestors: "
        SELECT n1.id, n1.parent_id, 0 AS depth, ARRAY[n1.id] AS path
        FROM nodes n1
        WHERE n1.id = #{another_node.id}

        UNION ALL

        SELECT t.id, t.parent_id, ta.depth + 1, ta.path || t.id
        FROM nodes t
        INNER JOIN another_node_ancestors ta ON t.id = ta.parent_id
        WHERE NOT t.id = ANY(ta.path)
      ",
      common_ancestors: "
        SELECT na.id, na.depth
        FROM node_ancestors na
        JOIN another_node_ancestors ana
        on na.id=ana.id
        ORDER BY na.depth, ana.depth
      "
    ).joins('JOIN common_ancestors ca ON ca.id = nodes.id').order('ca.depth')
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
      unless lowest_common_ancestor.nil?
        return { root_id: lowest_common_ancestor.root.id, lowest_common_ancestor: lowest_common_ancestor.id,
                 depth: lowest_common_ancestor.depth }
      end
    end
    { root_id: nil, lowest_common_ancestor: nil, depth: nil }
  end
end
