class CreateTransfers < ActiveRecord::Migration[8.0]
  def change
    create_table :transfers do |t|
      # トークンID
      t.references :token, null:false, foreign_key: true # token_id

      # ユーザー（送信者は必須、受信者はステータスが送信済になった際に追加）
      # 参照先テーブルを明示的に指定（カラム名とテーブル名が一致しないため）
      t.references :sender, null:false, foreign_key: { to_table: :users } # sender_id
      t.references :receiver, null:true, foreign_key: { to_table: :users } #receiver_id

      # 状態（received(受領済)=0, url_issued(URL発行済)=1, sent(送信済)=2）
      t.integer :status, null:false, default: 0

      # メッセージ
      t.text :message, null:true

      # 1つ前の履歴
      t.references :previous_transfer, null:true, foreign_key: { to_table: :transfers } # previous_transfer_id

      t.timestamps

      t.datetime :deleted_at
      t.index :deleted_at
    end
  end
end
