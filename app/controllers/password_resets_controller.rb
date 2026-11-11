# Forgot password: phone number -> 4-digit OTP -> new password
class PasswordResetsController < ApplicationController
  allow_unauthenticated_access
  rate_limit to: 5, within: 10.minutes, only: :create, with: -> { redirect_to new_password_reset_path, alert: "ขอ OTP บ่อยเกินไป กรุณารอสักครู่" }
  rate_limit to: 10, within: 10.minutes, only: :update, with: -> { redirect_to new_password_reset_path, alert: "ลองผิดบ่อยเกินไป กรุณารอสักครู่" }

  # Step 1: enter phone number
  def new
  end

  def create
    phone = params[:phone].to_s.gsub(/\D/, "")
    session[:password_reset_phone] = phone

    # Same response whether or not the phone exists, so nobody can probe which numbers are registered.
    notice = "ถ้าเบอร์นี้มีในระบบ เราได้ส่งรหัส OTP ไปแล้ว"
    if (user = User.find_by(phone: phone))
      code = user.generate_password_reset_otp!
      OtpSender.deliver(phone: user.phone, code: code)
      notice += " (dev: OTP คือ #{code})" if Rails.env.development?
    end

    redirect_to edit_password_reset_path, notice: notice
  end

  # Step 2: enter OTP + new password
  def edit
    redirect_to new_password_reset_path if session[:password_reset_phone].blank?
  end

  def update
    user = User.find_by(phone: session[:password_reset_phone].to_s)
    otp = Array(params[:otp]).join

    unless user&.verify_password_reset_otp(otp)
      return redirect_to edit_password_reset_path, alert: "รหัส OTP ไม่ถูกต้องหรือหมดอายุ"
    end

    if user.update(params.permit(:password, :password_confirmation))
      user.clear_password_reset_otp!
      user.sessions.destroy_all
      session.delete(:password_reset_phone)
      redirect_to new_session_path, notice: "ตั้งรหัสผ่านใหม่เรียบร้อย กรุณาเข้าสู่ระบบ"
    else
      redirect_to edit_password_reset_path, alert: user.errors.full_messages.to_sentence
    end
  end
end
