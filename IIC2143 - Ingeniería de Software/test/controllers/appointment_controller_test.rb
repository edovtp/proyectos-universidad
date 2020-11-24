require 'test_helper'

class AppointmentControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get appointment_new_url
    assert_response :success
  end

end
