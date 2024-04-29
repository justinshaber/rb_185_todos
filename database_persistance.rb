require 'pg'

class DatabasePersistance
  def initialize(logger)
    @db = PG.connect(dbname: "todos")
    @logger = logger
  end
  
  def all_lists
    sql = "SELECT * from lists"
    lists_result = query(sql)
    
    lists_result.map do |tuple|
      list_id = tuple["id"].to_i
      todos = find_todos_for_list(list_id)
      { id: tuple["id"].to_i, name: tuple["name"], todos: todos }
    end
  end
  
  def create_new_list(list_name)
    # id = next_item_id(@session[:lists]) 
    # @session[:lists] << { id: id, name: list_name, todos: [] }
  end
  
  def create_new_todo(list_id, todo_name)
    # list = find_list(list_id)
    # id = next_item_id(list[:todos])
    # list[:todos] << { id: id, name: todo_name, completed: false }
  end
  
  def delete_list(id)
    # @session[:lists].reject! { |list| list[:id] == id }
  end
  
  def delete_todo_from_list(list_id, todo_id)
    # list = find_list(list_id)
    # list[:todos].reject! { |todo| todo[:id] == todo_id }
  end
  
  def find_list(id)
    sql = "SELECT * FROM lists WHERE id = $1;"
    result = query(sql, id)
    
    tuple = result.first
    list_id = tuple["id"].to_i
    todos = find_todos_for_list(list_id)
    
    { id: list_id, name: tuple["name"], todos: todos }
  end
  
  def mark_all_todos_complete(list_id)
    # list = find_list(list_id)
    # list[:todos].each { |todo| todo[:completed] = true }
  end
  
  def select_list(id)
    # @session[:lists].select { |list| list[:id] == id }.first
  end
  
  def update_list_name(id, new_name)
    # list = find_list(id)
    # list[:name] = new_name
  end
  
  def update_todo_status(list_id, todo_id, change_status_to)
    # list = find_list(list_id)
    # current_todo = list[:todos].select { |todo| todo[:id] == todo_id }.first
    # toggle current_todo, change_status_to
  end
  
  private
  
  def find_todos_for_list(list_id)
    todo_sql = "SELECT * from todos WHERE list_id = $1"
    todos_result = query(todo_sql, list_id)
    
    todos_result.map do |todo_tuple|
      { id: todo_tuple["id"].to_i,
        name: todo_tuple["name"],
        completed: todo_tuple["completed"] == "t"
      }
    end
  end
  
  def query(statement, *params)
    @logger.info "#{statement}: #{params}"
    @db.exec_params(statement, params)
  end
  
  def toggle(todo, status)
    if status
      todo[:completed] = true
      @session[:success] = "The todo '#{todo[:name]}' has been checked off."
    else
      todo[:completed] = false
      @session[:success] = "The todo '#{todo[:name]}' has been unchecked."
    end
  end
end