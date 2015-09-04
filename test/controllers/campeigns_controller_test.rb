require 'test_helper'

class CampeignsControllerTest < ActionController::TestCase
  setup do
    @campeign = campeigns(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:campeigns)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create campeign" do
    assert_difference('Campeign.count') do
      post :create, campeign: { created_by: @campeign.created_by, description: @campeign.description, name: @campeign.name, status: @campeign.status, updated_by: @campeign.updated_by, user_id: @campeign.user_id }
    end

    assert_redirected_to campeign_path(assigns(:campeign))
  end

  test "should show campeign" do
    get :show, id: @campeign
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @campeign
    assert_response :success
  end

  test "should update campeign" do
    patch :update, id: @campeign, campeign: { created_by: @campeign.created_by, description: @campeign.description, name: @campeign.name, status: @campeign.status, updated_by: @campeign.updated_by, user_id: @campeign.user_id }
    assert_redirected_to campeign_path(assigns(:campeign))
  end

  test "should destroy campeign" do
    assert_difference('Campeign.count', -1) do
      delete :destroy, id: @campeign
    end

    assert_redirected_to campeigns_path
  end
end
