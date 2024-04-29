-- psql todos -f schema.sql

-- CREATE TABLE lists (
--   id serial PRIMARY KEY,
--   name text NOT NULL UNIQUE
-- );

-- CREATE TABLE todos (
--   id serial PRIMARY KEY,
--   name varchar(100) NOT NULL,
--   list_id integer NOT NULL REFERENCES list (id),
--   completed boolean NOT NULL DEFAULT false
-- );




-- NOT WORKING

-- if env["HTTP_X_REQUESTED_WITH"] == "XMLHttpRequest"
--     "/lists"
--   else
--     session[:success] = "The list '#{deleted_list[:name]}' has been deleted."
--     redirect "/lists"
--   end


