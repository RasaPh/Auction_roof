require "test_helper"

class Api::V1::UsersControllerTest < ActionDispatch::IntegrationTest
  test "POST /api/v1/user registers and logs in, then GET /api/v1/me returns the user" do
    post api_v1_user_path, as: :json, params: {
      user: { username: "apiuser", first_name: "A", last_name: "B", phone: "0833333333",
              password: "password123", password_confirmation: "password123" }
    }
    assert_response :created
    assert_equal "apiuser", response.parsed_body["username"]
    assert_nil response.parsed_body["password_digest"]

    get api_v1_me_path, as: :json
    assert_response :success
    assert_equal "apiuser", response.parsed_body["username"]
  end

  test "POST /api/v1/user with invalid data returns errors" do
    post api_v1_user_path, as: :json, params: { user: { username: "x" } }
    assert_response :unprocessable_entity
    assert response.parsed_body["errors"].key?("phone")
  end

  test "GET /api/v1/me without login returns 401" do
    get api_v1_me_path, as: :json
    assert_response :unauthorized
  end

  test "POST /api/v1/session logs in" do
    post api_v1_session_path, as: :json, params: { username: "one", password: "password" }
    assert_response :success

    get api_v1_me_path, as: :json
    assert_equal "one", response.parsed_body["username"]
  end

  test "POST /api/v1/session with wrong password returns 401" do
    post api_v1_session_path, as: :json, params: { username: "one", password: "nope" }
    assert_response :unauthorized
  end
end
