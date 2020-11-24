require 'test_helper'

class MenusControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get menus_new_url
    assert_response :success
  end

  test "should get index" do
    get menus_index_url
    assert_response :success
  end

  test "should get edit" do
    get menus_edit_url
    assert_response :success
  end

end
