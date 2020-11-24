require 'test_helper'

class LocalsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get locals_new_url
    assert_response :success
  end

  test "should get show" do
    get locals_show_url
    assert_response :success
  end

  test "should get index" do
    get locals_index_url
    assert_response :success
  end

  test "should get edit" do
    get locals_edit_url
    assert_response :success
  end

end
