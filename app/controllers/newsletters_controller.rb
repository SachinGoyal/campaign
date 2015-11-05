class NewslettersController < ApplicationController

  layout 'dashboard' # set custom layout 
    
  #filter
  before_action :authenticate_user!
  load_and_authorize_resource #cancan
  before_action :set_newsletter, only: [:show, :edit, :update, :destroy]
  before_action :set_templates, only: [:new, :create, :edit, :update]
  #filter

  # GET /newsletters
  # GET /newsletters.json
  def index
    @q = Newsletter.ransack(params[:q])
    @newsletters = @q.result(distinct: true).paginate(:page => params[:page], :per_page => 10)
  end


  def search
    # Contact.load_custom_attributes
    @q = Newsletter.ransack(params[:q])
    @newsletters = @q.result(distinct: true).paginate(:page => params[:page], :per_page => 10)
  end


  def show
  end

  def new
    @newsletter = Newsletter.new
    @newsletter_email = @newsletter.newsletter_emails.build(from_contacts: true)
    @sample_newsletter_email = @newsletter.newsletter_emails.build(sample: true)
  end

  def edit
    @newsletter_email = @newsletter.newsletter_emails.where(from_contacts: true).first || @newsletter.newsletter_emails.build(from_contacts: true)
    @sample_newsletter_email = @newsletter.newsletter_emails.where(sample: true).first || @newsletter.newsletter_emails.build(sample: true)
  end

  def edit_all
    Newsletter.edit_all(params[:group_ids], params[:get_action])  
    @newsletters = Newsletter.active
    action = params[:get_action].strip.capitalize
    @message = updateable_messages
  end

  def create
    @newsletter = Newsletter.new(newsletter_params)
    @templates = Template.active

    respond_to do |format|
      if @newsletter.save
        format.html { redirect_to @newsletter, notice: 'Newsletter was successfully created.' }
        format.json { render :show, status: :created, location: @newsletter }
      else
        format.html {
          email_attrs = params[:newsletter][:newsletter_emails_attributes]
          contact_emails = email_attrs[email_attrs.keys.first][:emails]
          sample_emails = email_attrs[email_attrs.keys.last][:emails]
          if contact_emails.blank?
            @newsletter_email = @newsletter.newsletter_emails.build(from_contacts: true)
          end

          if sample_emails.blank?
            @sample_newsletter_email = @newsletter.newsletter_emails.build(sample: true)
          end
          render :new 
        }
        format.json { render json: @newsletter.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @templates = Template.active
    respond_to do |format|
      if @newsletter.update(newsletter_params)
        format.html { redirect_to @newsletter, notice: 'Newsletter was successfully updated.' }
        format.json { render :show, status: :ok, location: @newsletter }
      else
        format.html { 
          # @sample_newsletter_email = @newsletter.newsletter_emails.where(:sample => true).try(:first)
          # @newsletter_email = @newsletter.newsletter_emails.where(:from_contacts => true).try(:first)
          render :edit 
        }
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
    def set_newsletter
      @newsletter = Newsletter.find(params[:id])
    end

    def newsletter_params
      params.require(:newsletter).permit(:campaign_id, :template_id, :name, :subject, :from_name, :from_address, :reply_email, :created_by, :updated_by, :bcc_email, :cc_email, :send_at, :profile_ids => [], :newsletter_emails_attributes => [ :emails, :sample, :from_contacts, :id ])
    end

    def updateable_messages
      "Newsletter deleted successfully. Newsletter with associated data could not be deleted."
    end

    def set_templates
      @templates = Template.active
    end
end
