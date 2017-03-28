class CreateCerttests < ActiveRecord::Migration
  def change
    create_table :certtests do |t|
      t.string :name
      t.text :description
      t.references :project, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
