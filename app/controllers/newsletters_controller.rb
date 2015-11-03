class NewslettersController < ApplicationController

  layout 'dashboard' # set custom layout 
    
  #filter
  before_action :authenticate_user!
  load_and_authorize_resource #cancan
  before_action :set_newsletter, only: [:show, :edit, :update, :destroy]
  #filter

  # GET /newsletters
  # GET /newsletters.json
  def index
    @q = Newsletter.ransack(params[:q])
    @newsletters = @q.result(distinct: true).paginate(:page => params[:page], :per_page => 10)
  end

  def search
    # Contact.load_custom_attributes
    @q = Contact.includes(:interest_areas).ransack(params[:q], auth_object: 'dummy')
    @contacts = @q.result(distinct: true).includes(:interest_areas).paginate(:page => params[:page], :per_page => 10)
  end
  # GET /newsletters/1
  # GET /newsletters/1.json
  def show
  end

  # GET /newsletters/new
  def new
    @newsletter = Newsletter.new
    @templates = Template.active
    @search = Contact.ransack(params[:q], auth_object: "dummy")
    @newsletters = @search.result(distinct: true).paginate(:page => params[:page], :per_page => 10)
  end

  # GET /newsletters/1/edit
  def edit
  end

  def edit_all
    Newsletter.edit_all(params[:group_ids], params[:get_action])  
    @newsletters = Newsletter.all
    action = params[:get_action].strip.capitalize
    @message = updateable_messages
  end


  # POST /newsletters
  # POST /newsletters.json
  def create
    @newsletter = Newsletter.new(newsletter_params)
    @templates = Template.active

    respond_to do |format|
      if @newsletter.save
        format.html { redirect_to @newsletter, notice: 'Newsletter was successfully created.' }
        format.json { render :show, status: :created, location: @newsletter }
      else
        format.html { render :new }
        format.json { render json: @newsletter.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /newsletters/1
  # PATCH/PUT /newsletters/1.json
  def update
    respond_to do |format|
      if @newsletter.update(newsletter_params)
        format.html { redirect_to @newsletter, notice: 'Newsletter was successfully updated.' }
        format.json { render :show, status: :ok, location: @newsletter }
      else
        format.html { render :edit }
        format.json { render json: @newsletter.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /newsletters/1
  # DELETE /newsletters/1.json
  def destroy
    @newsletter.destroy
    respond_to do |format|
      format.html { redirect_to newsletters_url, notice: 'Newsletter was successfully deleted.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_newsletter
      @newsletter = Newsletter.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def newsletter_params
      params.require(:newsletter).permit(:campaign_id, :template_id, :name, :subject, :from_name, :from_address, :reply_email, :created_by, :updated_by, :bcc_email, :cc_email)
    end

    def updateable_messages
      "Newsletter deleted successfully. Newsletter with associated data could not be deleted."
    end
end
