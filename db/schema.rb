# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2024_10_21_234132) do
  # These are extensions that must be enabled in order to support this database
  enable_extension 'ltree'
  enable_extension 'plpgsql'

  create_table 'birds', force: :cascade do |t|
    t.integer 'node_id'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index %w[id node_id], name: 'index_birds_on_id_and_node_id'
    t.index ['node_id'], name: 'index_birds_on_node_id'
  end

  create_table 'nodes', force: :cascade do |t|
    t.integer 'parent_id'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index %w[id parent_id], name: 'index_nodes_on_id_and_parent_id'
    t.index ['parent_id'], name: 'index_nodes_on_parent_id'
  end

  create_table 'tree', id: :integer, default: nil, force: :cascade do |t|
    t.integer 'parent_id'
  end

  create_table 'tree2', id: :integer, default: nil, force: :cascade do |t|
    t.ltree 'path'
  end

  create_function :get_ancestors, sql_definition: <<-SQL
      CREATE OR REPLACE FUNCTION public.get_ancestors(node_id integer)
       RETURNS TABLE(id bigint, depth integer)
       LANGUAGE plpgsql
      AS $function$
      BEGIN
        RETURN QUERY
        WITH RECURSIVE node_ancestors AS (
          -- TO DO, maybe persist this in a temp table instead of an array
          SELECT n1.id, n1.parent_id, 0 AS depth, ARRAY[n1.id] AS path
          FROM nodes n1
          WHERE n1.id = node_id
      #{'    '}
          UNION ALL
      #{'    '}
          -- Recursively select parents
          SELECT t.id, t.parent_id, ta.depth + 1, ta.path || t.id
          FROM nodes t
          INNER JOIN node_ancestors ta ON t.id = ta.parent_id
          -- Stop recursion if we've already visited this node (to prevent loops)
          WHERE NOT t.id = ANY(ta.path)
        )
        -- Return all ancestors
        SELECT na.id, na.depth
        FROM node_ancestors na
        WHERE na.id != node_id; -- Exclude the start node itself
      END;
      $function$
  SQL
  create_function :get_descendants, sql_definition: <<-SQL
      CREATE OR REPLACE FUNCTION public.get_descendants(node_id integer)
       RETURNS TABLE(id bigint, depth integer)
       LANGUAGE plpgsql
      AS $function$
      BEGIN
        RETURN QUERY
        WITH RECURSIVE node_descendants AS (
          -- Base case: start with the given node (start_id)
          SELECT n1.id, n1.parent_id, 0 AS depth, ARRAY[n1.id] AS path
          FROM nodes n1
          WHERE n1.id = node_id
      #{'    '}
          UNION ALL
      #{'    '}
          -- Recursive step: select children of each node found so far
          SELECT t.id, t.parent_id, td.depth + 1, td.path || t.id
          FROM nodes t
          INNER JOIN node_descendants td ON t.parent_id = td.id
          -- Stop recursion if we've already visited this node (to prevent loops)
          WHERE NOT t.id = ANY(td.path)
        )
        -- Return all descendants
        SELECT nd.id, nd.depth
        FROM node_descendants nd
        WHERE nd.id != node_id; -- Exclude the start node itself
      END;
      $function$
  SQL
  create_function :lowest_common_ancestor, sql_definition: <<-SQL
      CREATE OR REPLACE FUNCTION public.lowest_common_ancestor(node1 integer, node2 integer)
       RETURNS TABLE(root integer, lowest_common_ancestor integer, depth integer)
       LANGUAGE plpgsql
      AS $function$
      BEGIN
        -- Temporary CTEs to store ancestors of both nodes with depths
        WITH recursive ancestors_node1 AS (
          -- Base case: Start with node1 and depth 0
          SELECT * from get_ancestors(node1)
      #{'    '}
        ),
        ancestors_node2 AS (
          SELECT * from get_ancestors(node2)
        ),
        common_ancestors AS (
          -- Find common ancestors between node1 and node2
          SELECT an1.id AS common_ancestor, an1.depth AS depth_from_root
          FROM ancestors_node1 an1
          INNER JOIN ancestors_node2 an2 ON an1.id = an2.id
        )
        -- Select the root of node1 and the lowest common ancestor
        SELECT#{' '}
          -- The root is the ancestor of node1 with the highest depth (max depth in node1's ancestors)
          (SELECT id FROM ancestors_node1 ORDER BY ancestors_node1.depth DESC LIMIT 1) AS root,
          -- The lowest common ancestor is the common ancestor with the highest depth
          (SELECT common_ancestor FROM common_ancestors ORDER BY common_ancestors.depth_from_root DESC LIMIT 1) AS lowest_common_ancestor,
          -- Depth from the root to the lowest common ancestor
          (SELECT depth_from_root FROM common_ancestors ORDER BY common_ancestors.depth_from_root DESC LIMIT 1) AS depth
        INTO root, lowest_common_ancestor, depth;

        -- If no common ancestor was found, return NULLs
        IF root IS NULL OR lowest_common_ancestor IS NULL THEN
          RETURN QUERY SELECT NULL::INTEGER, NULL::INTEGER, NULL::INTEGER;
        END IF;

        RETURN;
      END;
      $function$
  SQL
  create_function :get_ancestors_and_self, sql_definition: <<-SQL
      CREATE OR REPLACE FUNCTION public.get_ancestors_and_self(node_id integer)
       RETURNS TABLE(id bigint, depth integer)
       LANGUAGE plpgsql
      AS $function$
      BEGIN
        RETURN QUERY
        WITH RECURSIVE node_ancestors AS (
          -- TO DO, maybe persist this in a temp table instead of an array
          SELECT n1.id, n1.parent_id, 0 AS depth, ARRAY[n1.id] AS path
          FROM nodes n1
          WHERE n1.id = node_id
      #{'    '}
          UNION ALL
      #{'    '}
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
      $function$
  SQL
  create_function :get_descendants_and_self, sql_definition: <<-SQL
      CREATE OR REPLACE FUNCTION public.get_descendants_and_self(node_id integer)
       RETURNS TABLE(id bigint, depth integer)
       LANGUAGE plpgsql
      AS $function$
      BEGIN
        RETURN QUERY
        WITH RECURSIVE node_descendants AS (
          -- Base case: start with the given node (start_id)
          SELECT n1.id, n1.parent_id, 0 AS depth, ARRAY[n1.id] AS path
          FROM nodes n1
          WHERE n1.id = node_id
      #{'    '}
          UNION ALL
      #{'    '}
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
      $function$
  SQL
  create_function :get_lowest_common_ancestor, sql_definition: <<-SQL
      CREATE OR REPLACE FUNCTION public.get_lowest_common_ancestor(node1_id integer, node2_id integer)
       RETURNS bigint
       LANGUAGE plpgsql
      AS $function$
      DECLARE
        lca_id BIGINT;
      BEGIN
        -- Find the lowest common ancestor by looking at shared ancestors and ordering by depth
        SELECT an1.id
        INTO lca_id
        FROM get_ancestors_and_self(node1_id) an1
        INNER JOIN get_ancestors_and_self(node2_id) an2 ON an1.id = an2.id
        ORDER BY an1.depth ASC
        LIMIT 1;

        -- Return the lowest common ancestor id, or NULL if no common ancestor is found
        RETURN lca_id;
      END;
      $function$
  SQL
  create_function :get_birds, sql_definition: <<-SQL
      CREATE OR REPLACE FUNCTION public.get_birds(node_ids integer[])
       RETURNS TABLE(id bigint)
       LANGUAGE plpgsql
      AS $function$
      BEGIN
        RETURN QUERY
        WITH RECURSIVE node_descendants AS (
          -- Base case: start with the given nodes (start_ids)
          SELECT nodes.id, nodes.parent_id, ARRAY[nodes.id] AS path
          FROM nodes
          WHERE nodes.id = ANY(node_ids)
      #{'    '}
          UNION ALL
      #{'    '}
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
      $function$
  SQL
end
