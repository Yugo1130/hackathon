class AddDeletedAtToUsers < ActiveRecord::Migration[8.0]
  def change
    # ユーザ削除時も履歴は削除しないためcascadeは不要
    # ユーザ削除時に外部キー制約でエラーになるのを防ぐため、論理削除用のdeleted_atカラムを追加
    add_column :users, :deleted_at, :datetime
    add_index :users, :deleted_at
  end
end
