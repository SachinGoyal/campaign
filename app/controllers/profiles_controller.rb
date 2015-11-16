class ProfilesController < ApplicationController 
  
  layout 'dashboard' # set custom layout   
  
  #filter
  before_action :authenticate_user!
  load_and_authorize_resource #cancan
  before_action :set_profile, only: [:show, :edit, :update, :destroy]
  #filter

  # GET /profiles
  # GET /profiles.json
  def index
    @q = Profile.ransack(params[:q], auth_object: "own")
    @profiles = @q.result.page(params[:page]).paginate(:page => params[:page], :per_page => 10)
  end

  def search
    association = Hash.new()
    # Contact.reflect_on_all_associations(:belongs_to).each { |a| association[a.foreign_key.to_s] = a.class_name }
    
    @attributes = Hash.new()

    Profile.columns_hash.slice('name', 'created_at').each do |k,v|
      @attributes[k] = {value: k, type: v.type.to_s, association: association[k]}
    end
    
    Attribute.columns_hash.slice('name').each do |k,v|
      @attributes["interest_areas_#{k}"] = {value: k, type: v.type.to_s, association: nil}
    end

    @q  = Profile.search(params[:q])
    @profiles = @q.result.includes(:interest_areas).page(params[:page]).paginate(:page => params[:page], :per_page => 10)

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
        format.html { redirect_to @profile, notice: 'Profile was successfully created.' }
        format.json { render :show, status: :created, location: @profile }
      else
        format.html { render :new }
        format.json { render json: @profile.errors, status: :unprocessable_entity }
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
    params[:profile][:interest_area_ids] ||= []
    respond_to do |format|
      if @profile.update(profile_params)
        format.html { redirect_to @profile, notice: 'Profile was successfully updated.' }
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
        format.html { redirect_to profiles_url, notice: 'Profile was successfully deleted.' }
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
        return redirect_to profiles_path, :alert => "Could not find profile"
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def profile_params
      params.require(:profile).permit(:name, :status, :created_by, :updated_by,interest_area_ids: [])
    end

    def updateable_messages(action)
      case action
        when 'Delete'
          "Profiles deleted successfully. Profiles with associated data could not be deleted."
        else
          "Profiles updated successfully."
      end

    end
end
