class ChatMessagesController < ApplicationController
  rate_limit to: 20, within: 1.minute, only: :create
  before_action :set_auction

  def create
    @chat_message = @auction.chat_messages.build(user: Current.user, body: params.expect(chat_message: [ :body ])[:body])
    if @auction.draft? || @auction.cancelled?
      head :not_found
    elsif @chat_message.save
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("chat_form", partial: "chat_messages/form", locals: { auction: @auction }) }
        format.html { redirect_to @auction }
      end
    else
      redirect_to @auction, alert: @chat_message.errors.full_messages.to_sentence
    end
  end

  def destroy
    return deny_access unless can?(:manage_auctions)
    @auction.chat_messages.find(params[:id]).destroy
    respond_to do |format|
      format.turbo_stream { head :no_content }
      format.html { redirect_to @auction, notice: "ลบข้อความแล้ว" }
    end
  end

  private
    def set_auction
      @auction = Auction.find(params[:auction_id])
    end
end
