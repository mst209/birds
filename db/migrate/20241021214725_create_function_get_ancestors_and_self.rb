class CreateFunctionGetAncestorsAndSelf < ActiveRecord::Migration[7.1]
  def change
    create_function :get_ancestors_and_self
  end
end
