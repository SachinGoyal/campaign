class RolesController < ApplicationController
  load_and_authorize_resource
  before_action :authenticate_user!
  before_action :set_role, only: [:show, :edit, :update, :destroy]

  # GET /roles
  # GET /roles.json
  def index
    @roles = Role.all
    # @roles = @search.result
    # @roles = @roles.paginate page: params[:page], per_page: 10

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @roles }
    end
  end

  # GET /roles/1
  # GET /roles/1.json
  def show
    @role = Role.find(params[:id])
    @functions = @role.functions.order('agroup').group_by(&:agroup)

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @role }
    end
  end

  # GET /roles/new
  # GET /roles/new.json
  def new
    @role = Role.new
    @functions = Function.all.group_by(&:agroup)
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @role }
    end
  end

  # POST /roles
  # POST /roles.json
  def create
    params.permit!
    @role = Role.new(params[:role])
    @functions = Function.all.group_by(&:agroup)
    respond_to do |format|
      if @role.save
        format.html { redirect_to [current_user ,@role], notice: t("frontend.role.confirm_created") }
        format.json { render json: @role, status: :created, location: @role }
      else
        format.html { render "new" }
        format.json { render json: @role.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /roles/1/edit
  def edit
    @functions = Function.all.group_by(&:agroup)
    @role = Role.find(params[:id])
  end


  # PUT /roles/1
  # PUT /roles/1.json
  def update
    params.permit!
    @role = Role.find(params[:id])
    @functions = Function.all.group_by(&:agroup) #need show
    respond_to do |format|
      if @role.update_attributes(params[:role])
        format.html { redirect_to [current_user,@role], notice: t("frontend.role.confirm_updated") }
        format.json { head :no_content }
      else
        format.html { render "edit" }
        format.json { render json: @role.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /roles/1
  # DELETE /roles/1.json
  def destroy
    role = Role.find(params[:id])
    if role.destroy
      respond_to do |format|
        format.html { redirect_to roles_url, alert: t("frontend.role.confirm_deleted") }
        format.json { head :no_content }
      end
    else
      redirect_to roles_path, alert: "#{role.errors.full_messages.join(" ")}"
    end
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_role
      @role = Role.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def role_params
      params.require(:role).permit(:name, :function_ids)
    end
end
