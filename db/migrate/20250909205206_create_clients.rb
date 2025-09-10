class CreateClients < ActiveRecord::Migration[8.0]
  def change
    create_table :clients do |t|
      t.string :name, null: false
      t.string :address, null: false
      t.string :city, null: false
      t.string :state, null: false
      t.string :cep, null: false
      t.string :phone, null: false
      t.string :cpf, null: false
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    add_index :clients, :cpf, unique: true
    add_index :clients, :name
    add_index :clients, :phone
  end
end
