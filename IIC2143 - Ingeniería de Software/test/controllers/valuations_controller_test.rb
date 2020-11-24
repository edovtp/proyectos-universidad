require 'test_helper'

class ValuationsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get valuations_new_url
    assert_response :success
  end

end
