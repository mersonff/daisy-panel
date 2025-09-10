class CreateImportReports < ActiveRecord::Migration[8.0]
  def change
    create_table :import_reports do |t|
      t.references :user, null: false, foreign_key: true
      t.string :filename
      t.string :status
      t.integer :success_count
      t.integer :error_count
      t.integer :total_lines
      t.datetime :started_at
      t.datetime :completed_at
      t.text :error_details

      t.timestamps
    end
  end
end
