class CreateInvalidTees < ActiveRecord::Migration[5.1]
  def change
    create_table :invalid_tees do |t|
      t.references :user, foreign_key: true
      t.references :club, foreign_key: true
      t.datetime :start_date
      t.datetime :end_date
      t.integer :number_time_slots

      t.timestamps
    end
  end
end
