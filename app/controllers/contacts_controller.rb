class ContactsController < ApplicationController
  
  layout 'dashboard' # set custom layout 
  before_action :authenticate_user!
  load_and_authorize_resource #cancan

  before_action :set_contact, only: [:show, :edit, :update, :destroy]

  def sample_fields
    if params[:profile_id].present?
      @profile = Profile.find(params[:profile_id]) 
    else
      @profile = nil
    end

  end

  def dynamic_field
    @contact = Contact.new
    @profile = Profile.find(params[:profile_id])
    @extra_fields = @profile.extra_fields
  end

  def import  
    Contact.import_records(params[:file], params[:profile_id])  
    redirect_to profiles_path, notice: t("controller.contact.import")  
  end  
 
  def search
    association = Hash.new()    
    @attributes = Hash.new()

    Contact.columns_hash.slice('first_name', 'email', 'last_name', 'created_at').each do |k,v|
      @attributes[k] = {value: k, type: v.type.to_s, association: association[k]}
    end
    
    # Attribute.columns_hash.slice('name').each do |k,v|
    #   @attributes["interest_areas_#{k}"] = {value: k, type: v.type.to_s, association: nil}
    # end
    @q  = Contact.search(params[:q])
    @contacts = @q.result.includes(:interest_areas).page(params[:page]).paginate(:page => params[:page], :per_page => 10)
    @q.build_condition    
  end

  # GET /contacts
  # GET /contacts.json
  def index
    if params[:q] and params[:q][:auth_object] == "newsletter"
      @q = Contact.ransack(params[:q], auth_object: 'newsletter')
      @contacts = @q.result
    else
      @q = Contact.ransack(params[:q])
      @contacts = @q.result.page(params[:page]).paginate(:page => params[:page], :per_page => 10)       
    end    
    contacts = @q.result
    
    respond_to do |format|
      format.html 
      format.js
      # if current_user.is_admin?
      #   format.csv { send_data contacts.to_admin_csv(col_sep: "\t",profile_id: params[:profile_id]) }
      #   format.xls { send_data contacts.to_admin_csv(col_sep: "\t",profile_id: params[:profile_id]) }

      # else
        format.csv { send_data contacts.to_csv }
        format.xls { send_data contacts.to_csv(col_sep: "\t",profile_id: params[:profile_id])}
     # end        
    end
  end

  # GET /contacts/1
  # GET /contacts/1.json
  def show
  end

  # GET /contacts/new
  def new
    @contact = Contact.new
  end

  # POST /contacts
  # POST /contacts.json
  def create
    params.permit!
    @contact = Contact.new(params[:contact])
    respond_to do |format|
      if @contact.save
        format.html { return redirect_to @contact, notice: t("controller.shared.flash.create.notice", model: pick_model_from_locale(:contact)) }
        format.json { render :show, status: :created, location: @contact }
      else
        format.html { render :new }
        format.json { render json: @contact.errors, status: t("controller.shared.flash.create.status") }
      end
    end
  end

  # GET /contacts/1/edit
  def edit

  end

  # GET /contacts/edit_all
  def edit_all
    Contact.edit_all(params[:group_ids], params[:get_action])  
    @contacts = Contact.all
    action = params[:get_action].strip.capitalize
    @message = updateable_messages(action)
  end


  # PATCH/PUT /contacts/1
  # PATCH/PUT /contacts/1.json
  def update
    params.permit!
    @contact = Contact.find(params[:id])
    @contact.attributes = params[:contact]

    respond_to do |format|
      if @contact.update(params[:contact])
        format.html { redirect_to @contact, notice: t("controller.shared.flash.update.notice", model: pick_model_from_locale(:contact)) }
        format.json { render :show, status: :ok, location: @contact }
      else
        format.html { render :edit }
        format.json { render json: @contact.errors, status: t("controller.shared.flash.update.status") }
      end
    end
  end

  # DELETE /contacts/1
  # DELETE /contacts/1.json
  def destroy
    @contact.destroy
    respond_to do |format|
      format.html { redirect_to contacts_url, notice: t("controller.shared.flash.destroy.notice", model: pick_model_from_locale(:contact)) }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_contact
      @contact = Contact.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def contact_params
      params.require(:contact).permit(:email, :status, :profile_id)
    end

    def updateable_messages(action)
      case action
        when 'Delete'
          t("controller.shared.flash.delete_all", model: pick_model_from_locale(:contact))
        else
          t("controller.shared.flash.edit_all.notice.update_all", model: pick_model_from_locale(:contact))
      end
    end
end
