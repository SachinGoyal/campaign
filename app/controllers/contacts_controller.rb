class ContactsController < ApplicationController
  
  layout 'dashboard' # set custom layout 
  
  load_and_authorize_resource #cancan

  #filter
  before_action :authenticate_user!
  before_action :set_contact, only: [:show, :edit, :update, :destroy]
  #filter

  def import  
    Contact.import_records(params[:file], params[:profile_id])  
    redirect_to root_url, notice: "Contacts imported."  
  end  
  # GET /contacts
  # GET /contacts.json
  def index
    @contacts = Contact.all
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
    respond_to do |format|
      if @contact.save
        format.html { redirect_to @contact, notice: 'Contact was successfully created.' }
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
    Contact.edit_all(params[:contacts_id], params[:get_action])  
    redirect_to index
  end


  # PATCH/PUT /contacts/1
  # PATCH/PUT /contacts/1.json
  def update
    params[:contact][:interest_area_ids] ||= []
    @contact = Contact.find(params[:id])
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
      params.require(:contact).permit(:first_name, :last_name, :email, :status, :created_by, :updated_by, interest_area_ids: [])
    end
end
