class RolesController < ApplicationController

  layout 'dashboard' # set custom layout 
  
  #filter
  before_action :authenticate_user!
  load_and_authorize_resource #cancan
  before_action :set_role, only: [:show, :edit, :update, :destroy]
  #filter

  # GET /roles
  # GET /roles.json
  def index
    if current_user.is_admin?
      @q = Role.where(editable: true).ransack(params[:q])
    else
      @q = Role.where.not(name: COMPANY_ADMIN).where(editable: true).ransack(params[:q])
    end
    @roles = @q.result.paginate(:page => params[:page], :per_page => 10)

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
    @role = Role.new(role_params)
    @functions = Function.all.group_by(&:agroup)
    respond_to do |format|
      if @role.save
        format.html { redirect_to  @role, notice: t("controller.shared.flash.create.notice", model: "Role") }
        format.json { render json: @role, status: :created, location: @role }
      else
        format.html { render "new" }
        format.json { render json: @role.errors, status: t("controller.shared.flash.create.status") }
      end
    end
  end

  # GET /roles/1/edit
  def edit
    @role = Role.find(params[:id])
    @functions = Function.all.group_by(&:agroup)
  end

  # GET /contacts/edit_all
  def edit_all
    Role.edit_all(params[:group_ids], params[:get_action])  
    @roles = Role.where(editable: true).paginate(:page => params[:page], :per_page => 10)
    @functions = Function.all.group_by(&:agroup)
    action = params[:get_action].strip.capitalize
    @message = updateable_messages(action)
  end



  # PUT /roles/1
  # PUT /roles/1.json
  def update
    params[:role][:function_ids] ||= []
    @role = Role.find(params[:id])
    @functions = Function.all.group_by(&:agroup) #need show
    respond_to do |format|
      if @role.update_attributes(role_params)
        @role.assign_permission if @role.id == COMPANY_ADMIN_ID
        format.html { redirect_to @role, notice: t("controller.shared.flash.update.notice", model: "Role") }
        format.json { head :no_content }
      else
        format.html { render "edit" }
        format.json { render json: @role.errors, status: t("controller.shared.flash.update.status") }
      end
    end
  end

  # DELETE /roles/1
  # DELETE /roles/1.json
  def destroy
    role = Role.find(params[:id])
    if role.destroy
      respond_to do |format|
        format.html { redirect_to roles_url, notice: t("controller.shared.flash.destroy.notice", model: "Role") }
        format.json { head :no_content }
      end
    else
      redirect_to roles_path, notice: "#{role.errors.full_messages.join(", ")}"
    end
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_role
      @role = Role.find(params[:id])
      unless @role
        return redirect_to roles_path, :alert => t("controller.shared.alert.message" , model: 'Role')
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def role_params
      params.require(:role).permit(:name, :company_id, function_ids: [])
    end

    def updateable_messages(action)
      case action
        when 'Delete'
          t("controller.shared.flash.delete_all", model: "Role")
        else
          t("controller.shared.flash.edit_all.notice.update_all", model: "Role")
      end

  end
end
