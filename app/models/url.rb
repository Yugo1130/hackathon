class Url < ApplicationRecord
    belongs_to :transfer

    # 論理削除されていないものだけ取得
    scope :active, -> { where(deleted_at: nil) }

    # バリデーション
    validates :slug, presence: true, uniqueness: true

    # コールバック，slugを自動生成
    before_validation :ensure_slug, on: :create

    # 論理削除メソッド
    def soft_delete
        update(deleted_at: Time.current)
    end

    private

    def ensure_slug
        self.slug ||= SecureRandom.urlsafe_base64(24)
    end
end
