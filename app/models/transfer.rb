class Transfer < ApplicationRecord
    belongs_to :token
    belongs_to :sender, class_name: 'User'
    belongs_to :receiver, class_name: 'User', optional: true
    belongs_to :previous_transfer, class_name: 'Transfer', optional: true
    has_one :url, dependent: :destroy

    enum status: {
        received:   0,  # 受領済（自分が受け取った）
        url_issued: 1,  # URL発行済
        sent:       2,  # 送付済（相手に渡した）
    }

    # 論理削除されていないものだけ取得
    scope :active, -> { where(deleted_at: nil) }

    # バリデーション
    validates :status, presence: true

    # 論理削除メソッド
    def soft_delete
        update(deleted_at: Time.current)
    end
end
