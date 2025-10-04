class User < ApplicationRecord
  has_many :sent_transfers, class_name: 'Transfer', foreign_key: 'sender_id'
  has_many :received_transfers, class_name: 'Transfer', foreign_key: 'receiver_id'
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  validates :name, presence: true, length: { maximum: 50 }


  # 論理削除されていないものだけ取得
  scope :active, -> { where(deleted_at: nil) }

  # 論理削除メソッド
  def soft_delete
      update(deleted_at: Time.current)
  end
end
