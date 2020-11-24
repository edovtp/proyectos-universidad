require 'test_helper'

class InterestsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get interests_new_url
    assert_response :success
  end

  test "should get index" do
    get interests_index_url
    assert_response :success
  end

  test "should get show" do
    get interests_show_url
    assert_response :success
  end

  test "should get edit" do
    get interests_edit_url
    assert_response :success
  end

end
