class TransfersController < ApplicationController
  before_action :set_transfer, only: %i[ show edit update destroy ]
  before_action :set_transfer_by_slug!, only: %i[ show_by_slug receive ]  # ← 追加

  # GET /transfers or /transfers.json
  def index
    @transfers = Transfer.where(status: :sent).order(updated_at: :desc)
  end

  # GET /transfers/1 or /transfers/1.json
  def show
  end

  # GET /transfers/new
  def new
    @transfer = Transfer.new
  end

  # GET /transfers/1/edit
  def edit
  end

  # POST /transfers or /transfers.json
  def create
    @transfer = Transfer.new(transfer_params)

    respond_to do |format|
      if @transfer.save
        format.html { redirect_to @transfer, notice: "Transfer was successfully created." }
        format.json { render :show, status: :created, location: @transfer }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @transfer.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /transfers/1 or /transfers/1.json
  def update
    # 送付済の譲渡情報は編集不可
    if @transfer.sent?
      redirect_to edit_transfer_path(@transfer), alert: "送付済の譲渡情報は編集できません。"
      return
    end

    ActiveRecord::Base.transaction do
      # updateではmessageのみ更新可能
      @transfer.assign_attributes(transfer_params_update)

      # 「URLを発行して保存」ボタンから来たか（今回はこの1ボタンのみ）
      if params[:issue_url].present?
        @transfer.status = :url_issued
        @transfer.slug = generate_unique_slug(except_id: @transfer.id)
      end
      @transfer.save!
    end

    redirect_to edit_transfer_path(@transfer), notice: "リンクを発行しました"
  rescue ActiveRecord::RecordInvalid => e
    flash.now[:alert] = "保存に失敗しました: #{e.record.errors.full_messages.join(', ')}"
    render :edit, status: :unprocessable_entity
  end

  # DELETE /transfers/1 or /transfers/1.json
  def destroy
    @transfer.destroy!

    respond_to do |format|
      format.html { redirect_to transfers_path, notice: "Transfer was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  def show_by_slug
    @transfer = Transfer.active.where(status: :url_issued).find_by!(slug: params[:slug])
    @token = @transfer.token
    render :receive
  rescue ActiveRecord::RecordNotFound
    redirect_to mypage_path, alert: "無効なリンクです。"
  end

  def receive
    # 自分が送信者になっている譲渡情報は受け取れない
    if @transfer.sender == current_user
      redirect_to mypage_path, alert: "自分が送信者のバトンは受け取れません。"
      return
    end
    # 既に受け取られている譲渡情報は受け取れない
    if @transfer.status != "url_issued"
      redirect_to mypage_path, alert: "このバトンは既に受け取られています。"
      return 
    end
    @transfer.receive!(current_user)
    redirect_to transfer_path(@transfer), notice: "バトンを受け取りました。"
  rescue ActiveRecord::RecordInvalid => e
    redirect_to mypage_path, alert: "バトンの受け取りに失敗しました。#{e.message}"
  end        

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_transfer
      @transfer = Transfer.find(params[:id])
    end

    def set_transfer_by_slug!
      @transfer = Transfer.active.where(status: :url_issued).find_by!(slug: params[:slug])
      @token = @transfer.token  # 関連するバトン
    rescue ActiveRecord::RecordNotFound
      redirect_to mypage_path, alert: "無効なURLです。"
    end

    # slugを一意に生成
    # except_id: 自分自身のIDを除外する（更新時用）
    def generate_unique_slug(except_id: nil)
      loop do
        slug = SecureRandom.uuid

        # 自分以外に同じslugが無ければ採用
        clash = Transfer.where(slug: slug)
        clash = clash.where.not(id: except_id) if except_id
        return slug unless clash.exists?
      end
    end

    # Only allow a list of trusted parameters through.
    def transfer_params
      params.require(:transfer).permit(
        :message, :token_id, :sender_id, :receiver_id, :previous_transfer_id, :status, :slug
      )
    end

    def transfer_params_update
      params.require(:transfer).permit(
        :message
      )
    end
end
