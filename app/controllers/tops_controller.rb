class TopsController < ApplicationController
  before_action :set_top, only: %i[]

  # GET /tops or /tops.json
  def index
    @tops = Top.all

    @today_chains = Transfer.today_chains
    @total_chains = Transfer.total_chains
    @total_tokens = Token.total_tokens
    @longest_token_length = Token.longest_token_length
    
  end

 
end
