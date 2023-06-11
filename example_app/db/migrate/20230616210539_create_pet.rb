class CreatePet < ActiveRecord::Migration[7.0]
  def change
    create_table :pets do |t|
      t.string :name
      t.date :date_of_birth
      t.string :animal
      t.integer :owner_id

      t.timestamps
    end
  end
end
