class CreateTags < ActiveRecord::Migration
  def change
    create_table :tags do |t|
      t.string :keyword
      t.integer :creator_id, {null: false}

      t.timestamps null: false
    end
    add_index :tags, :creator_id
  end
end
