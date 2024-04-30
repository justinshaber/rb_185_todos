-- psql todos -f schema.sql

-- CREATE TABLE lists (
--   id serial PRIMARY KEY,
--   name text NOT NULL UNIQUE
-- );

-- CREATE TABLE todos (
--   id serial PRIMARY KEY,
--   name varchar(100) NOT NULL,
--   list_id integer NOT NULL REFERENCES lists (id),
--   completed boolean NOT NULL DEFAULT false
-- );


-- SELECT lists.*,
--           count(todos.id) as todos_count,
--           count(nullif(todos.completed, true)) as todos_remaining_count
--         FROM lists
--         JOIN todos ON todos.list_id = lists.id
--         WHERE lists.id = 22
--         GROUP BY lists.id
--         ORDER BY lists.name;
  
SELECT lists.*,
          count(todos.id) as todos_count,
          count(nullif(todos.completed, true)) as todos_remaining_count
        FROM lists
        LEFT JOIN todos ON todos.list_id = lists.id
        GROUP BY lists.id
        ORDER BY lists.name;

-- SELECT * from lists
--   JOIN todos ON todos.list_id = lists.id;
  
-- SELECT * from lists;