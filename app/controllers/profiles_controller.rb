class ProfilesController < ApplicationController 
  
  layout 'dashboard' # set custom layout   
  
  #filter
  before_action :authenticate_user!
  load_and_authorize_resource #cancan
  before_action :set_profile, only: [:show, :edit, :update, :destroy]
  before_action :check_deactivation, only: [:update]
  #filter

  # GET /profiles
  # GET /profiles.json
  def index
    @q = Profile.ransack(params[:q], auth_object: "own")
    @profiles = @q.result.page(params[:page]).paginate(:page => params[:page], :per_page => 10)
  end

  def search
    association = Hash.new()    
    @attributes = Hash.new()

    Profile.columns_hash.slice('name', 'created_at').each do |k,v|
      @attributes[k] = {value: k, type: v.type.to_s, association: association[k]}
    end
    
    @q  = Profile.search(params[:q])
    @profiles = @q.result.page(params[:page]).paginate(:page => params[:page], :per_page => 10)

    @q.build_condition    
  end

  # GET /profiles/1
  # GET /profiles/1.json
  def show
  end

  # GET /profiles/new
  def new
    @profile = Profile.new
  end
  
  # POST /profiles
  # POST /profiles.json
  def create
    @profile = Profile.new(profile_params)

    respond_to do |format|
      if @profile.save
        format.html { redirect_to @profile, notice: t("controller.shared.flash.create.notice", model: pick_model_from_locale(:profile)) }
        format.json { render :show, status: :created, location: @profile }
      else
        format.html { render :new }
        format.json { render json: @profile.errors, status: t("controller.shared.flash.create.status") }
      end
    end
  end

  # GET /profiles/1/edit
  def edit
  end

  # GET /profiles/edit_all
  def edit_all
    Profile.edit_all(params[:group_ids], params[:get_action])  
    @profiles = Profile.all.paginate(:page => params[:page], :per_page => 10)
    action = params[:get_action].strip.capitalize
    @message = updateable_messages(action)
  end

 

  # PATCH/PUT /profiles/1
  # PATCH/PUT /profiles/1.json
  def update
    respond_to do |format|
      if @profile.update(profile_params)
        format.html { redirect_to @profile, notice: t("controller.shared.flash.update.notice", model: pick_model_from_locale(:profile)) }
        format.json { render :show, status: :ok, location: @profile }
      else
        format.html { render :edit }
        format.json { render json: @profile.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /profiles/1
  # DELETE /profiles/1.json
  def destroy
    respond_to do |format|
      if @profile.destroy
        format.html { redirect_to profiles_url, notice: t("controller.shared.flash.destroy.notice", model: pick_model_from_locale(:profile)) }
        format.json { head :no_content }
      else
        format.html { redirect_to profiles_url, notice: @profile.errors.full_messages.join(", ") }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_profile
      @profile = Profile.find(params[:id])
      unless @profile
        return redirect_to profiles_path, :alert => t("controller.shared.alert.message" , model: pick_model_from_locale(:profile))
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def profile_params
      params.require(:profile).permit(:name, :description, :status,extra_fields_attributes: [:id,:field_name,
                                                   :field_type, :_destroy])
    end

    def updateable_messages(action)

      case action
        when 'Delete'
          t("controller.profile.delete_all", model: pick_model_from_locale(:profile))
        when 'Disable'
          t("controller.profile.disable_all", model: pick_model_from_locale(:profile))
        else
          t("controller.shared.flash.edit_all.notice.update_all", model: pick_model_from_locale(:profile))
      end
    end

    def check_deactivation
      if params[:profile] and params[:profile][:status]
        profile_status_bool = ActiveRecord::Type::Boolean.new.type_cast_from_user(params[:profile][:status])
        if profile_status_bool == false and profile_status_bool != @profile.status and @profile.newsletter_emails.count > 0
          return redirect_to edit_profile_path(@profile), notice: t('activerecord.errors.models.profile.attributes.base.newsletters_exist')
        end
      end
    end
end
