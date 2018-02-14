class CreateThingTags < ActiveRecord::Migration
  def change
    create_table :thing_tags do |t|
      t.references :tag, {index: true, foreign_key: true, null: false}
      t.references :thing, {index: true, foreign_key: true, null: false}
      t.integer :creator_id, {null: false}

      t.timestamps null: false
    end
    add_index :thing_tags, [:tag_id, :thing_id], unique: true
  end
end
