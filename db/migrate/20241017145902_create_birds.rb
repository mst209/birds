class CreateBirds < ActiveRecord::Migration[7.1]
  def change
    create_table :birds do |t|
      t.integer :node_id
      t.index :node_id
      t.index %i[id node_id]
      t.timestamps
    end
  end
end
