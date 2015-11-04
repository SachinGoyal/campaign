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
    @users = @q.result(distinct: true).paginate(:page => params[:page], :per_page => 10)
  end

  def search
    @attributes = Hash.new()

    User.columns_hash.slice('first_name', 'email', 'last_name', 'created_at').each do |k,v|
      @attributes[k] = {value: k, type: v.type.to_s, association: nil}
    end

    @search = User.search(params[:q])
    @users = @search.result(distinct: true).page(params[:page]).paginate(:page => params[:page], :per_page => 10)
    @search.build_condition    
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
        format.html { redirect_to @user, notice: 'User was successfully created.' }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def show
  end

  def edit
  end

  def edit_all
    User.edit_all(params[:group_ids], params[:get_action])  
    @users = User.all
    action = params[:get_action].strip.capitalize
    @message = updateable_messages(action)
  end

  def update
    params[:user].delete(:password) if params[:user][:password].blank?
    params[:user].delete(:password_confirmation) if params[:user][:password].blank? and params[:user][:password_confirmation].blank?
    if @user.update_attributes(user_params)
      flash[:notice] = "Successfully updated User."
      redirect_to users_path
    else
      render :action => 'edit'
    end
  end

  def destroy
    if @user.role.try(:name) == COMPANY_ADMIN
      return redirect_to users_path, :notice => "Cannot delete user with company admin role"
    end

  	if @user.destroy
  	 redirect_to users_path, :success => "Successfully deleted user"
    else
      redirect_to users_path, :notice => @user.errors.full_messages.join(", ")
    end
  end

	private
	# Use callbacks to share common setup or constraints between actions.
	def set_user
	  @user = User.find(params[:id])
    unless @user
      return redirect_to users_path, :alert => "Could not find user"
    end
	end

	# Never trust parameters from the scary internet, only allow the white list through.
	def user_params
	  params.require(:user).permit(:username, :email, :status, :password, :password_confirmation, :role_id, :image, :company_id)
  end

  def updateable_messages(action)
    case action
      when 'Delete'
        "Users deleted successfully. Users with associated data or company admin role could not be deleted."
      else
        "Users updated successfully."
    end

  end

end
