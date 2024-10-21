CREATE OR REPLACE FUNCTION get_ancestors_and_self(node_id INTEGER)
RETURNS TABLE(id BIGINT, depth INTEGER) AS $$
BEGIN
  RETURN QUERY
  WITH RECURSIVE node_ancestors AS (
    -- TO DO, maybe persist this in a temp table instead of an array
    SELECT n1.id, n1.parent_id, 0 AS depth, ARRAY[n1.id] AS path
    FROM nodes n1
    WHERE n1.id = node_id
    
    UNION ALL
    
    -- Recursively select parents
    SELECT t.id, t.parent_id, ta.depth + 1, ta.path || t.id
    FROM nodes t
    INNER JOIN node_ancestors ta ON t.id = ta.parent_id
    -- Stop recursion if we've already visited this node (to prevent loops)
    WHERE NOT t.id = ANY(ta.path)
  )
  -- Return all ancestors
  SELECT na.id, na.depth
  FROM node_ancestors na;
END;
$$ LANGUAGE plpgsql;