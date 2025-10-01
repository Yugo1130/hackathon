class CreateTokens < ActiveRecord::Migration[8.0]
  def change
    create_table :tokens do |t|
      t.timestamps

      t.datetime :deleted_at
      t.index :deleted_at
    end
  end
end
