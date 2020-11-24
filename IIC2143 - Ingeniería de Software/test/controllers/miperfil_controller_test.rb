require 'test_helper'

class MiperfilControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get miperfil_show_url
    assert_response :success
  end

end
