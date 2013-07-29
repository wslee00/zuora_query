require 'test_helper'

class QueryToolControllerTest < ActionController::TestCase
  test "should get view" do
    get :view
    assert_response :success
  end

end
