class CreateFunctionGetDescendants < ActiveRecord::Migration[7.1]
  def change
    create_function :get_descendants
  end
end
