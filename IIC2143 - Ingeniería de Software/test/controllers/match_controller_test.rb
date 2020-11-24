require 'test_helper'

class MatchControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get match_show_url
    assert_response :success
  end

end
