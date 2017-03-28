require 'test_helper'

class CerttestsControllerTest < ActionController::TestCase
  setup do
    @certtest = certtests(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:certtests)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create certtest" do
    assert_difference('Certtest.count') do
      post :create, certtest: { description: @certtest.description, name: @certtest.name, project_id: @certtest.project_id }
    end

    assert_redirected_to certtest_path(assigns(:certtest))
  end

  test "should show certtest" do
    get :show, id: @certtest
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @certtest
    assert_response :success
  end

  test "should update certtest" do
    patch :update, id: @certtest, certtest: { description: @certtest.description, name: @certtest.name, project_id: @certtest.project_id }
    assert_redirected_to certtest_path(assigns(:certtest))
  end

  test "should destroy certtest" do
    assert_difference('Certtest.count', -1) do
      delete :destroy, id: @certtest
    end

    assert_redirected_to certtests_path
  end
end
