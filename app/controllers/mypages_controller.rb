class MypagesController < ApplicationController
  before_action :authenticate_user!  # ログイン必須

  def show
    @user = current_user
    
    # 所持しているトークン
    @owned_tokens = 
      Token.joins(:transfers)
           .merge(@user.sent_transfers.active.where(status: [:received, :url_issued]).order(updated_at: :desc))

    # 受信履歴
    @received_token_transfers = 
      @user.received_transfers
           .active
           .order(updated_at: :desc)
    
    # 送信履歴
    @sent_token_transfers = 
      @user.sent_transfers
           .active
           .where(status: :sent)
           .order(created_at: :desc)
  end
end
