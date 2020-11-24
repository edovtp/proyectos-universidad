require 'test_helper'

class CommunesControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get communes_new_url
    assert_response :success
  end

  test "should get index" do
    get communes_index_url
    assert_response :success
  end

  test "should get show" do
    get communes_show_url
    assert_response :success
  end

  test "should get edit" do
    get communes_edit_url
    assert_response :success
  end

end
