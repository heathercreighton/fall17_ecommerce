require 'test_helper'

class AdminControllerTest < ActionDispatch::IntegrationTest
  test "should get all_user" do
    get admin_all_user_url
    assert_response :success
  end

  test "should get edit_user" do
    get admin_edit_user_url
    assert_response :success
  end

  test "should get show_user" do
    get admin_show_user_url
    assert_response :success
  end

end
