class UsersController < ApplicationController
  
  layout 'dashboard' # set custom layout 

  #filter
  before_action :authenticate_user!
  load_and_authorize_resource #cancan
  skip_authorize_resource :only => :search  

  before_action :set_user, only: [:show, :edit, :update, :destroy]
  #filter

  
  def index
    @q = User.where.not(id: 1).ransack(params[:q])
    @users = @q.result.paginate(:page => params[:page], :per_page => 10)
  end

  def search
    @attributes = Hash.new()

    User.columns_hash.slice('first_name', 'email', 'last_name', 'created_at' , 'username' , 'status').each do |k,v|
      @attributes[k] = {value: k, type: v.type.to_s, association: nil}
    end

    @q = User.search(params[:q])
    @users = @q.result.page(params[:page]).paginate(:page => params[:page], :per_page => 10)
    @q.build_condition    
    @users = @users.where.not(id: 1)
  end

  def new
  	@user = User.new
  end

  def create
    @user = User.new(user_params)
    respond_to do |format|
      if @user.save
        @user.confirm!
        user = User.invite!(:email => @user.email) do |u|
          u.skip_invitation = true
        end
        @user.deliver_invitation
        format.html { redirect_to @user, notice: t("controller.shared.flash.create.notice", model: "User") }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new }
        format.json { render json: @user.errors, status: t("controller.shared.flash.create.status") }
      end
    end
  end

  def show
  end

  def edit
  end

  def edit_all
    User.edit_all(params[:group_ids], params[:get_action])  
    @users = User.all.paginate(:page => params[:page], :per_page => 10)
    action = params[:get_action].strip.capitalize
    @message = updateable_messages(action)
  end

  def update
    params[:user].delete(:password) if params[:user][:password].blank?
    params[:user].delete(:password_confirmation) if params[:user][:password].blank? and params[:user][:password_confirmation].blank?
    if @user.update_attributes(user_params)
      flash[:notice] = t("controller.shared.flash.update.notice", model: "User")
      redirect_to users_path
    else
      render :action => 'edit'
    end
  end

  def destroy
    if @user.role.try(:name) == COMPANY_ADMIN
      return redirect_to users_path, :notice => t("controller.user.delete")
    end

  	if @user.destroy
  	 redirect_to users_path, :success => t("controller.shared.flash.destroy.notice", model: "User")
    else
      redirect_to users_path, :notice => @user.errors.full_messages.join(", ")
    end
  end

	private
	# Use callbacks to share common setup or constraints between actions.
	def set_user
	  @user = User.find(params[:id])
    unless @user
      return redirect_to users_path, :alert => t("controller.shared.alert.message" , model: 'User')
    end
	end

	# Never trust parameters from the scary internet, only allow the white list through.
	def user_params
	  params.require(:user).permit(:username, :email, :status, :password, :password_confirmation, :role_id, :image, :company_id)
  end

  def updateable_messages(action)
    case action
      when 'Delete'
        t("controller.user.delete_all")
      else
        t("controller.shared.flash.edit_all.notice.update_all", model: "User")
    end

  end

end
