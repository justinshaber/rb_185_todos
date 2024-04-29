class SessionPersistance
  def initialize(session)
    @session = session
    @session[:lists] ||= []
  end
  
  def all_lists
    @session[:lists]
  end
  
  def create_new_list(list_name)
    id = next_item_id(@session[:lists]) 
    @session[:lists] << { id: id, name: list_name, todos: [] }
  end
  
  def create_new_todo(list_id, todo_name)
    list = find_list(list_id)
    id = next_item_id(list[:todos])
    list[:todos] << { id: id, name: todo_name, completed: false }
  end
  
  def delete_list(id)
    @session[:lists].reject! { |list| list[:id] == id }
  end
  
  def delete_todo_from_list(list_id, todo_id)
    list = find_list(list_id)
    list[:todos].reject! { |todo| todo[:id] == todo_id }
  end
  
  def find_list(id)
    @session[:lists].select { |list| list[:id] == id }.first
  end
  
  def mark_all_todos_complete(list_id)
    list = find_list(list_id)
    list[:todos].each { |todo| todo[:completed] = true }
  end
  
  def select_list(id)
    @session[:lists].select { |list| list[:id] == id }.first
  end
  
  def update_list_name(id, new_name)
    list = find_list(id)
    list[:name] = new_name
  end
  
  def update_todo_status(list_id, todo_id, change_status_to)
    list = find_list(list_id)
    current_todo = list[:todos].select { |todo| todo[:id] == todo_id }.first
    toggle current_todo, change_status_to
  end
  
  private
  
  def next_item_id(items)
    max = items.map { |item| item[:id] }.max || 0
    max + 1
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