CREATE OR REPLACE FUNCTION get_descendants_and_self(node_id INTEGER)
RETURNS TABLE(id BIGINT, depth INTEGER) AS $$
BEGIN
  RETURN QUERY
  WITH RECURSIVE node_descendants AS (
    -- Base case: start with the given node (start_id)
    SELECT n1.id, n1.parent_id, 0 AS depth, ARRAY[n1.id] AS path
    FROM nodes n1
    WHERE n1.id = node_id
    
    UNION ALL
    
    -- Recursive step: select children of each node found so far
    SELECT t.id, t.parent_id, td.depth + 1, td.path || t.id
    FROM nodes t
    INNER JOIN node_descendants td ON t.parent_id = td.id
    -- Stop recursion if we've already visited this node (to prevent loops)
    WHERE NOT t.id = ANY(td.path)
  )
  -- Return all descendants
  SELECT nd.id, nd.depth
  FROM node_descendants nd;
END;
$$ LANGUAGE plpgsql;