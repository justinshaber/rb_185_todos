# bundle exec ruby todo.rb -p $PORT -o $IP

require 'sinatra'
require 'sinatra/reloader' if development?
require 'sinatra/content_for'
require 'tilt/erubis'

# require_relative 'session_persistance'
require_relative 'database_persistance'

configure do
  enable :sessions
  set :session_secret, SecureRandom.hex(32)
  set :erb, :escape_html => true
end

helpers do
  def completed?(todo)
    "complete" if todo[:completed]
  end

  def list_completed?(list)
    "complete" if count_incomplete_todos(list) == 0 &&
                    count_total_todos(list) > 0
  end

  def count_incomplete_todos(list)
    list[:todos].reduce(0) do |total, todo|
      !todo[:completed] ? total + 1 : total
    end
  end

  def count_total_todos(list)
    list[:todos].size
  end

  def sort_lists(list, &block)
    indexed_list = list.map.with_index { |list, index| [list, index] }
    sorted_list = indexed_list.sort_by { |list, _ | list_completed?(list) ? 1 : 0 }

    sorted_list.each(&block)
  end

  def sort_todos(todos, &block)
    sorted_todos = todos.sort_by { |todo, _| todo[:completed] ? 1 : 0 }
    sorted_todos.each(&block)
  end
end

# Return an error message if name is invalid. Return nil if name is valid.
def error_for_list_name(name)
  if !(1..100).cover? name.size
    'List must be between 1 and 100 characters.'
  elsif @storage.all_lists.any? { |list| list[:name] == name }
    'List name must be unique.'
  end
end

# Validate the list at index _ exists
def load_list(list_id)
  list = @storage.find_list(list_id)
  return list if list

  session[:error] = "The specified list was not found."
  redirect "/lists"
end

def error_for_todo_name(name)
  if !(1..100).cover? name.size
    'Todo must be between 1 and 100 characters.'
  end
end

before do
  @storage = DatabasePersistance.new(logger)
end

get "/" do
  redirect "/lists"
end

# View list of lists
get "/lists" do
  @lists = @storage.all_lists
  erb :lists, layout: :layout
end

# Render the new list form
get "/lists/new" do
  erb :new_list, layout: :layout
end

# Create a new list
post "/lists" do
  list_name = params[:list_name].strip

  error = error_for_list_name(list_name)
  if error
    session[:error] = error
    erb :new_list, layout: :layout
  else
    @storage.create_new_list(list_name)
    session[:success] = 'The list has been created.'
    redirect "/lists"
  end
end

# Update an existing todo list
post "/lists/:list_id" do
  list_name = params[:list_name].strip
  @list_id = params[:list_id].to_i
  @current_list = load_list(@list_id)

  error = error_for_list_name(list_name)
  if error
    session[:error] = error
    erb :edit_list, layout: :layout
  else
    @storage.update_list_name(@list_id, list_name)
    session[:success] = 'The list has been renamed.'
    redirect "/lists/#{@list_id}"
  end
end

# View a todo list
get "/lists/:list_id" do
  @list_id = params[:list_id].to_i
  
  @current_list = load_list(@list_id)
  erb :single_list, layout: :layout
end

# View single list name editing page
get "/lists/:list_id/edit" do
  @list_id = params[:list_id].to_i
  @current_list = load_list(@list_id)

  erb :edit_list, layout: :layout
end

# Delete an entire todo list
post "/lists/:list_id/delete" do
  list_id = params[:list_id].to_i
  deleted_list = @storage.select_list(list_id)
  
  @storage.delete_list(list_id)
  
  session[:success] = "The list '#{deleted_list[:name]}' has been deleted."
  if env["HTTP_X_REQUESTED_WITH"] == "XMLHttpRequest"
    "/lists"
  else
    redirect "/lists"
  end
end

# Add a todo item to a list
post "/lists/:list_id/todos" do
  todo = params[:todo].strip
  @list_id = params[:list_id].to_i
  @current_list = load_list(@list_id)

  error = error_for_todo_name(todo)
  if error
    session[:error] = error
    erb :single_list, layout: :layout
  else
    @storage.create_new_todo(@list_id, todo)
    session[:success] = "The todo '#{todo}' was added."
    redirect "/lists/#{@list_id}"
  end
end

# Delete a todo list item
post "/lists/:list_id/todos/:todo_id/delete" do
  @list_id = params[:list_id].to_i
  @todo_id = params[:todo_id].to_i
  @current_list = load_list(@list_id)

  @storage.delete_todo_from_list(@list_id, @todo_id)

  if env["HTTP_X_REQUESTED_WITH"] == "XMLHttpRequest"
    status 204
  else
    session[:success] = "The todo has been deleted."
    redirect "/lists/#{@list_id}"
  end
end

# Toggle a todo list item as complete or incomplete
post "/lists/:list_id/todos/:todo_id" do
  @list_id = params[:list_id].to_i
  @todo_id = params[:todo_id].to_i
  @current_list = load_list(@list_id)
  change_status_to = params[:completed] == "true"
  
  @storage.update_todo_status(@list_id, @todo_id, change_status_to)
  redirect "/lists/#{@list_id}"
end

# Mark all todos as complete
post "/lists/:list_id/complete_all" do
  @list_id = params[:list_id].to_i
  @current_list = load_list(@list_id)
  @storage.mark_all_todos_complete(@list_id)

  session[:success] = "All todos have been completed."
  redirect "/lists/#{@list_id}"
end
