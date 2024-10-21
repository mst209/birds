class CreateFunctionGetDescendantsAndSelf < ActiveRecord::Migration[7.1]
  def change
    create_function :get_descendants_and_self
  end
end
