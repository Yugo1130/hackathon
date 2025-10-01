class CreateUrls < ActiveRecord::Migration[8.0]
  def change
    create_table :urls do |t|
      t.references :transfer, null:false, foreign_key: true # transfer_id

      # スラッグ（URLの一部として使用される一意の識別子）
      t.string :slug, null:false

      t.timestamps

      t.datetime :deleted_at
      t.index :deleted_at
      t.index :slug, unique: true
    end
  end
end
