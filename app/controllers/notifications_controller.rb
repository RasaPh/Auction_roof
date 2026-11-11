class NotificationsController < ApplicationController
  layout "site"

  def index
    @notifications = Current.user.notifications.includes(:auction).recent.limit(100)
  end

  def read
    notification = Current.user.notifications.find(params[:id])
    notification.update!(read_at: Time.current) unless notification.read?
    redirect_to notification.auction || notifications_path
  end

  def read_all
    Current.user.notifications.unread.update_all(read_at: Time.current)
    redirect_to notifications_path, notice: "อ่านทั้งหมดแล้ว"
  end
end
