class ContactsController < ApplicationController
  
  layout 'dashboard' # set custom layout 
  before_action :authenticate_user!
  load_and_authorize_resource #cancan

  #filter
  before_action :set_contact, only: [:show, :edit, :update, :destroy]
  #filter

  def import  
    Contact.import_records(params[:file], params[:profile_id])  
    redirect_to profiles_path, notice: "Contacts imported."  
  end  
 
  def search
    association = Hash.new()
    # Contact.reflect_on_all_associations(:belongs_to).each { |a| association[a.foreign_key.to_s] = a.class_name }
    
    @attributes = Hash.new()

    Contact.columns_hash.slice('first_name', 'email', 'last_name', 'created_at').each do |k,v|
      @attributes[k] = {value: k, type: v.type.to_s, association: association[k]}
    end
    
    Attribute.columns_hash.slice('name').each do |k,v|
      @attributes["interest_areas_#{k}"] = {value: k, type: v.type.to_s, association: nil}
    end
    @q  = Contact.search(params[:q])
    @contacts = @q.result(distinct: true).includes(:interest_areas).page(params[:page]).paginate(:page => params[:page], :per_page => 10)
    @q.build_condition    
  end

  # GET /contacts
  # GET /contacts.json
  def index
    @q = Contact.ransack(params[:q])
    @contacts = @q.result(distinct: true).page(params[:page]).paginate(:page => params[:page], :per_page => 10)       
    contacts = @q.result(distinct: true)
    respond_to do |format|
      format.html
      if current_user.is_admin?
        format.csv { send_data contacts.to_admin_csv }
        format.xls { send_data contacts.to_admin_csv(col_sep: "\t") }
      else
        format.csv { send_data contacts.to_csv }
        format.xls { send_data contacts.to_csv(col_sep: "\t") }
      end        
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
    @contact = Contact.new(contact_params)
    if (contact_params[:profile_ids] - [""]).empty? 
      @contact.valid?
      @contact.errors[:profile_ids] << "Please select atleast one"
      render :new
      return
    end
    
    respond_to do |format|
      if @contact.save
        format.html { return redirect_to @contact, notice: 'Contact was successfully created.' }
        format.json { render :show, status: :created, location: @contact }
      else
        format.html { render :new }
        format.json { render json: @contact.errors, status: :unprocessable_entity }
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
    params[:contact][:interest_area_ids] ||= []
    @contact = Contact.find(params[:id])
    @contact.attributes = contact_params

    if (contact_params[:profile_ids] - [""]).empty? 
      @contact.valid?
      @contact.errors[:profile_ids] << "Please select atleast one"
      render :new
      return
    end

    if (contact_params[:profile_ids] - [""]).empty? and !@contact.valid?
      @contact.errors[:profile_ids] << "Please select atleast one"
      render :new
      return
    end

    respond_to do |format|
      if @contact.update(contact_params)
        format.html { redirect_to @contact, notice: 'Contact was successfully updated.' }
        format.json { render :show, status: :ok, location: @contact }
      else
        format.html { render :edit }
        format.json { render json: @contact.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /contacts/1
  # DELETE /contacts/1.json
  def destroy
    @contact.destroy
    respond_to do |format|
      format.html { redirect_to contacts_url, notice: 'Contact was successfully destroyed.' }
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
      params.require(:contact).permit(:first_name, :last_name, :email, :status, :country, :city, :gender, :created_by, :updated_by, interest_area_ids: [],profile_ids: [])
    end

    def updateable_messages(action)
      case action
        when 'Delete'
          "Contacts deleted successfully."
        else
          "Contacts updated successfully."
      end
    end
end
