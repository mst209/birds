class CreateFunctionGetDescendantBirds < ActiveRecord::Migration[7.1]
  def change
    create_function :get_descendant_birds
  end
end
