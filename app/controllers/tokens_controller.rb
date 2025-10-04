class TokensController < ApplicationController
  before_action :set_token, only: %i[ show edit update destroy ]

  # GET /tokens or /tokens.json
  def index
    # 送信済みのリレー数でソートして取得
    @tokens = Token
      .left_joins(:transfers)
      .select('tokens.*, COUNT(transfers.id) AS sent_count')
      .group('tokens.id')
      .order('sent_count DESC, tokens.created_at DESC') # 同数のとき新しい順
  end

  # GET /tokens/1 or /tokens/1.json
  def show
    @all_transfers = @token.transfers.active.where(status: :sent).order(created_at: :asc)

    @current_holder = @token.transfers.active.where(status: [:received, :url_issued]).order(updated_at: :desc).first&.sender

    @my_sent_transfers = @all_transfers.where(sender: current_user)

    @my_received_transfers = @all_transfers.where(receiver: current_user)

    @chain_count = @all_transfers.size

    # 自分でなければnilが入る
    @editable_transfer = @token.latest_editable_transfer(current_user)
  end

  # GET /tokens/new
  def new
    @token = Token.new
  end

  # GET /tokens/1/edit
  def edit
  end

  # POST /tokens or /tokens.json
  def create
    # トークン発行，移転履歴の作成をトランザクションでまとめて実行
    ActiveRecord::Base.transaction do
      # トークンを新規作成
      @token = Token.create!(token_params)

      # トークンの最初の譲渡情報を作成（送信者は自分、ステータスは受領済）
      @token.transfers.create!(
        token: @token,
        sender: current_user,
        status: :received,
      )
    end

    flash[:notice] = "新しいトークンを発行しました。"
    redirect_to token_path(@token)

    rescue ActiveRecord::RecordInvalid => e
      flash[:alert] = "トークンの発行に失敗しました。#{e.message}"
      redirect_to mypage_path
    ensure
  end

  # PATCH/PUT /tokens/1 or /tokens/1.json
  def update
    respond_to do |format|
      if @token.update(token_params)
        format.html { redirect_to @token, notice: "Token was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @token }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @token.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tokens/1 or /tokens/1.json
  def destroy
    @token.destroy!

    respond_to do |format|
      format.html { redirect_to tokens_path, notice: "Token was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_token
      @token = Token.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def token_params
      params.fetch(:token, {})
    end
end
