CREATE OR REPLACE FUNCTION get_birds(node_ids INTEGER[])
RETURNS TABLE(id BIGINT) AS $$
BEGIN
  RETURN QUERY
  WITH RECURSIVE node_descendants AS (
    -- Base case: start with the given nodes (start_ids)
    SELECT nodes.id, nodes.parent_id, ARRAY[nodes.id] AS path
    FROM nodes
    WHERE nodes.id = ANY(node_ids)
    
    UNION ALL
    
    -- Recursive step: select children of each node found so far
    SELECT t.id, t.parent_id, td.path || t.id
    FROM nodes t
    INNER JOIN node_descendants td ON t.parent_id = td.id
    -- Stop recursion if we've already visited this node (to prevent loops)
    WHERE NOT t.id = ANY(td.path)
  )
  -- Return distinct descendants excluding the start nodes
  SELECT DISTINCT b.id
  FROM node_descendants nd
  JOIN birds b on b.node_id = nd.id;
END;
$$ LANGUAGE plpgsql;