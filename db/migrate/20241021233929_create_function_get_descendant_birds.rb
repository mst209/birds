class CreateFunctionGetBirds < ActiveRecord::Migration[7.1]
  def change
    create_function :descendant_birds
  end
end
