require 'test_helper'

class NewslettersControllerTest < ActionController::TestCase
  setup do
    @newsletter = newsletters(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:newsletters)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create newsletter" do
    assert_difference('Newsletter.count') do
      post :create, newsletter: { campeign_id: @newsletter.campeign_id, created_by: @newsletter.created_by, from_address: @newsletter.from_address, from_name: @newsletter.from_name, name: @newsletter.name, reply_email: @newsletter.reply_email, subject: @newsletter.subject, template_id: @newsletter.template_id, updated_by: @newsletter.updated_by }
    end

    assert_redirected_to newsletter_path(assigns(:newsletter))
  end

  test "should show newsletter" do
    get :show, id: @newsletter
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @newsletter
    assert_response :success
  end

  test "should update newsletter" do
    patch :update, id: @newsletter, newsletter: { campeign_id: @newsletter.campeign_id, created_by: @newsletter.created_by, from_address: @newsletter.from_address, from_name: @newsletter.from_name, name: @newsletter.name, reply_email: @newsletter.reply_email, subject: @newsletter.subject, template_id: @newsletter.template_id, updated_by: @newsletter.updated_by }
    assert_redirected_to newsletter_path(assigns(:newsletter))
  end

  test "should destroy newsletter" do
    assert_difference('Newsletter.count', -1) do
      delete :destroy, id: @newsletter
    end

    assert_redirected_to newsletters_path
  end
end
