class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  
  def index
    if current_user.is_superadmin?
      @search = User.search(params[:q])
      @users = @search.result
      @search.build_condition    
    else current_user.is_companyadmin?
      @users = current_user.company.users
  	  @q = User.ransack(params[:q])
      @users = @q.result(distinct: true)
    end    
  end

  def new
  	@user = User.new
  end

  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
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
  	@user = User.find(params[:id])
  	@user.destroy
  	redirect_to users_path, :notice => "successfully deleted"
  end

	private
	# Use callbacks to share common setup or constraints between actions.
	def set_user
	  @user = User.find(params[:id])
	end

	# Never trust parameters from the scary internet, only allow the white list through.
	def user_params
	  params.require(:user).permit(:username, :email, :status, :password, :password_confirmation)
	end

end