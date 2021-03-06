class CreateSchools < ActiveRecord::Migration[4.2]
  def change
    create_table :schools do |t|
      t.string :school_name
      t.boolean :enabled, default: true
      t.references :organization, index: true, foreign_key: true
      t.timestamps null: false
    end
  end
end
