class CreateValidTees < ActiveRecord::Migration[5.1]
  def change
    create_table :valid_tees do |t|
      t.references :user, foreign_key: true
      t.references :club, foreign_key: true
      t.datetime :datetime

      t.timestamps
    end
  end
end
