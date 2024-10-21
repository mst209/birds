class CreateFunctionGetBirds < ActiveRecord::Migration[7.1]
  def change
    create_function :get_birds
  end
end
