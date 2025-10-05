class Transfer < ApplicationRecord
    belongs_to :token
    belongs_to :sender, class_name: 'User'
    belongs_to :receiver, class_name: 'User', optional: true
    belongs_to :previous_transfer, class_name: 'Transfer', optional: true

    enum :status, {
        received:   0,  # 受領済（自分が受け取った）
        url_issued: 1,  # URL発行済
        sent:       2,  # 送付済（相手に渡した）
    }

    # 論理削除されていないものだけ取得
    scope :active, -> { where(deleted_at: nil) }
    # 作成日時の降順で取得
    scope :latest_first, -> { order(created_at: :desc) }
    # 編集可能な譲渡情報だけ取得（statusがreceivedまたはurl_issuedのもの）
    scope :editable, -> { where(status: [:received, :url_issued]) }

    # バリデーション
    validates :status, presence: true
    validates :slug, uniqueness: true, allow_nil: true

    # 論理削除メソッド
    def soft_delete
        update(deleted_at: Time.current)
    end

    # URL発行
    def issue_url!
        update!(status: :url_issued, slug: (slug || SecureRandom.uuid))
    end

    # 受領（リレーを伸ばす）
    def receive!(receiver_user)
        transaction do
            # 既存の譲渡情報を送付済に更新
            update!(receiver: receiver_user, status: :sent)
            # 新しい譲渡情報を作成（送信者は自分、ステータスは受領済）
            token.transfers.create!(
                token: token,
                sender: receiver_user,
                previous_transfer: self,
                status: :received,
            )
        end
    end

    # 今日のリレー数
    def self.today_chains
        where(status: :sent).
          where("updated_at >= ?", Time.zone.now.beginning_of_day).count
    end

    #　全体のリレー数
    def self.total_chains
        where(status: :sent).count
    end
end
