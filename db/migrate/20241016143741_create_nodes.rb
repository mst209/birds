# frozen_string_literal: true

class CreateNodes < ActiveRecord::Migration[7.1]
  def change
    create_table :nodes do |t|
      t.integer :parent_id
      t.index :parent_id
      t.index %i[id parent_id]
      t.timestamps
    end
  end
end
