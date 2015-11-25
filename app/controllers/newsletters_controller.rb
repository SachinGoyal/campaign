class NewslettersController < ApplicationController

  layout 'dashboard' # set custom layout 
    
  #filter
  before_action :authenticate_user!
  load_and_authorize_resource #cancan
  before_action :set_newsletter, only: [:show, :edit, :update, :destroy]
  before_action :set_templates, only: [:new, :create, :edit, :update]
  before_action :check_editable_or_deletable, only: [:edit, :update, :destroy]
  #filter

  # GET /newsletters
  # GET /newsletters.json
  def index
    @q = Newsletter.ransack(params[:q], auth_object: 'own')
    @newsletters = @q.result.paginate(:page => params[:page], :per_page => 10)
  end


  def search
    @attributes = Hash.new()

    Newsletter.columns_hash.slice('name', 'subject', 'created_at').each do |k,v|
      @attributes[k] = {value: k, type: v.type.to_s, association: nil}
    end

    @q = Newsletter.search(params[:q], auth_object: 'own')
    @newsletters = @q.result.page(params[:page]).paginate(:page => params[:page], :per_page => 10)
    @q.build_condition    
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
    @newsletters = Newsletter.all.paginate(:page => params[:page], :per_page => 10)
    action = params[:get_action].strip.capitalize
    @message = updateable_messages
  end

  def create
    @newsletter = Newsletter.new(newsletter_params)

    respond_to do |format|
      if @newsletter.save
        format.html { redirect_to @newsletter, notice: t("controller.shared.flash.create.notice", model: pick_model_from_locale(:newsletter)) }
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
        format.json { render json: @newsletter.errors, status: t("controller.shared.flash.create.status") }
      end
    end
  end

  def update
    respond_to do |format|
      if @newsletter.update(newsletter_params)
        format.html { redirect_to @newsletter, notice: t("controller.shared.flash.update.notice", model: pick_model_from_locale(:newsletter)) }
        format.json { render :show, status: :ok, location: @newsletter }
      else
        format.html { 
          # @sample_newsletter_email = @newsletter.newsletter_emails.where(:sample => true).try(:first)
          # @newsletter_email = @newsletter.newsletter_emails.where(:from_contacts => true).try(:first)
          render :edit 
        }
        format.json { render json: @newsletter.errors, status: t("controller.shared.flash.update.status") }
      end
    end
  end

  # DELETE /newsletters/1
  # DELETE /newsletters/1.json
  def destroy
    @newsletter.destroy
    respond_to do |format|
      format.html { redirect_to newsletters_url, notice: t("controller.shared.flash.destroy.notice", model: pick_model_from_locale(:newsletter)) }
      format.json { head :no_content }
    end
  end

  def send_now
    return redirect_to newsletters_path
  end

  private

    def set_newsletter
      @newsletter = Newsletter.find(params[:id])
    end

    def newsletter_params
      params.require(:newsletter).permit(:campaign_id, :template_id, :name, :subject, :from_name, :from_address, :reply_email, :created_by, :updated_by, :bcc_email, :cc_email, :send_at, :profile_ids => [], :newsletter_emails_attributes => [ :emails, :sample, :from_contacts, :id ])
    end

    def updateable_messages
      t("controller.newsletter.updateable_messages")
    end

    def set_templates
      @templates = Template.active
    end

    def check_editable_or_deletable
      unless @newsletter.editable_or_deletable?
        return redirect_to newsletters_path, :notice => t("controller.newsletter.check_editable_or_deletable")
      end
    end
end
