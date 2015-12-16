class CompaniesController < ApplicationController

  layout 'dashboard' # set custom layout 
  before_action :authenticate_user!
  load_and_authorize_resource :except => [:select_roles] #cancan

  #filter
  before_action :set_company, only: [:show, :edit, :update, :destroy, :select_roles]
  #filter

  # GET /companies
  # GET /companies.json
  def index
    @q = Company.ransack(params[:q])
    @companies = @q.result.paginate(:page => params[:page], :per_page => 10)
  end

  def search
    @attributes = Hash.new()

    Company.columns_hash.slice('name', 'subdomain', 'created_at', 'status' , 'free_emails').each do |k,v|
      @attributes[k] = {value: k, type: v.type.to_s, association: nil}
    end

    @q  = Company.search(params[:q])
   # @q.sorts = 'id desc' if @q.sorts.empty?
    @companies = @q.result.page(params[:page]).paginate(:page => params[:page], :per_page => 10)
    @q.build_condition    
  end

  # GET /companies/1
  # GET /companies/1.json
  def show
  end

  # GET /companies/new
  def new
    @company = Company.new
    @company.users.build
  end

  # GET /companies/1/edit
  def edit
  end

  def edit_all
    Company.edit_all(params[:group_ids], params[:get_action])  
    @companies = Company.all.paginate(:page => params[:page], :per_page => 10)
    action = params[:get_action].strip.capitalize
    @message = updateable_messages(action)
  end

  # POST /companies
  # POST /companies.json
  def create
    @company = Company.new(company_params)
    @company.creator = current_user
    respond_to do |format|
      if @company.save
        @user = @company.users.first
        @user.confirm!
        @user = User.invite!(:email => @user.email) do |u|
          u.skip_invitation = true
        end
        @user.deliver_invitation
        @company.create_role
        format.html { redirect_to @company, notice: t("controller.shared.flash.create.notice", model: pick_model_from_locale(:company)) }
        format.json { render :show, status: :created, location: @company }
      else
        format.html { render :new }
        format.json { render json: @company.errors, status: t("controller.shared.flash.create.status") }
      end
    end
  end

  # PATCH/PUT /companies/1
  # PATCH/PUT /companies/1.json
  def update
    @company.updator = current_user
    respond_to do |format|
      if @company.update(company_params)
        format.html { redirect_to @company, notice: t("controller.shared.flash.update.notice", model: pick_model_from_locale(:company)) }
        format.json { render :show, status: :ok, location: @company }
      else
        format.html { render :edit }
        format.json { render json: @company.errors, status: t("controller.shared.flash.update.status") }
      end
    end
  end

  # DELETE /companies/1
  # DELETE /companies/1.json
  def destroy
    respond_to do |format|
      if @company.destroy
        format.html { redirect_to companies_url, notice: t("controller.shared.flash.destroy.notice", model: pick_model_from_locale(:company)) }
        format.json { head :no_content }
      else
        format.html { redirect_to companies_url, notice: @company.errors.full_messages.join(", ") }
      end
    end
  end

  def select_roles
    @user = User.find(params[:user_id]) if params[:user_id].present?
    @roles = Role.where(company_id: @company.id, editable: true)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_company
      @company = Company.find(params[:id])
      unless @company
        return redirect_to companies_path, :alert => t("controller.shared.alert.message" , model: pick_model_from_locale(:company))
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def company_params
      params.require(:company).permit(:name, :free_emails, :status, :created_by, :updated_by, :subdomain, :company_logo, users_attributes: [:id, :email, :username, :password, :password_confirmation, :role_id, :status])
    end

    def updateable_messages(action)
      case action
        when 'Delete'
          t("controller.shared.flash.delete_all", model: pick_model_from_locale(:company))
        else
          t("controller.shared.flash.edit_all.notice.update_all", model: pick_model_from_locale(:company))
      end

    end
end
