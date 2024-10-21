class CreateFunctionGetAncestors < ActiveRecord::Migration[7.1]
  def change
    create_function :get_ancestors
  end
end
