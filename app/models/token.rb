class Token < ApplicationRecord
    has_many :transfers

    # 論理削除されていないものだけ取得
    scope :active, -> { where(deleted_at: nil) }
    
    # 論理削除メソッド
    def soft_delete
        update(deleted_at: Time.current)
    end

    # 現在の所有者を取得（statusがreceivedまたはurl_issuedの最新のTransfer）
    def current_transfer
        transfers.where(status: [:received, :url_issued]).order(created_at: :desc).first
    end

    # 編集可能な最新の譲渡情報を取得
    def latest_editable_transfer
        transfers
            .editable
            .where(sender: current_user)
            .order(created_at: :desc)
            .first
    end

    # 送付済の譲渡情報のチェーンを取得（created_atの昇順）
    def chain
        transfers.active.where(status: :sent).order(created_at: :asc)
    end

    # トークン数
    def self.total_tokens
        count
    end

    # 最長チェーンの長さ
    def self.longest_token_length
        joins(:transfers)
            .where(transfers: { status: :sent })
            .group("tokens.id")
            .count("transfers.id")
            .values
            .max || 0
    end
end
