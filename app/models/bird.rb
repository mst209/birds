class Bird < ApplicationRecord
  belongs_to :node

  def self.search_by_node_ids(node_ids)
    Bird.with(
      :recursive,
      node_descendants: "
      SELECT n1.id, n1.parent_id, 0 AS depth, ARRAY[n1.id] AS path
      FROM nodes n1
      WHERE n1.id IN (#{node_ids.join(',')})

      UNION ALL

      SELECT t.id, t.parent_id, td.depth + 1, td.path || t.id
      FROM nodes t
      INNER JOIN node_descendants td ON t.parent_id = td.id
      WHERE NOT t.id = ANY(td.path)
    "
    ).joins('JOIN node_descendants nd ON birds.node_id = nd.id').distinct.order(:id).map(&:id)
  end
end
