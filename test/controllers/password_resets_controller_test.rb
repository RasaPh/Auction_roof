require "test_helper"

class PasswordResetsControllerTest < ActionDispatch::IntegrationTest
  setup { @user = users(:one) }


  test "full flow: phone -> OTP -> new password" do
    sent = capture_otp { post password_reset_path, params: { phone: "081-111-1111" } }
    assert_redirected_to edit_password_reset_path
    assert_match(/\A\d{4}\z/, sent)

    patch password_reset_path, params: { otp: sent.chars, password: "newpassword1", password_confirmation: "newpassword1" }
    assert_redirected_to new_session_path
    assert User.authenticate_by(username: "one", password: "newpassword1")
    assert_nil @user.reload.otp_digest
  end

  test "unknown phone gets the same response" do
    post password_reset_path, params: { phone: "0899999999" }
    assert_redirected_to edit_password_reset_path
  end

  test "wrong OTP is rejected and locks after max attempts" do
    sent = capture_otp { post password_reset_path, params: { phone: @user.phone } }
    wrong = ((sent.to_i + 1) % 10_000).to_s.rjust(4, "0")

    User::OTP_MAX_ATTEMPTS.times do
      patch password_reset_path, params: { otp: wrong.chars, password: "newpassword1", password_confirmation: "newpassword1" }
      assert_redirected_to edit_password_reset_path
    end

    # Even the right code no longer works
    patch password_reset_path, params: { otp: sent.chars, password: "newpassword1", password_confirmation: "newpassword1" }
    assert_redirected_to edit_password_reset_path
    assert_nil User.authenticate_by(username: "one", password: "newpassword1")
  end

  test "expired OTP is rejected" do
    sent = capture_otp { post password_reset_path, params: { phone: @user.phone } }

    travel 11.minutes do
      patch password_reset_path, params: { otp: sent.chars, password: "newpassword1", password_confirmation: "newpassword1" }
    end
    assert_redirected_to edit_password_reset_path
  end
end
