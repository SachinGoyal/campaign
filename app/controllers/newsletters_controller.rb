class NewslettersController < ApplicationController

  layout 'dashboard' 
    
  #filter
  before_action :authenticate_user!
  load_and_authorize_resource 
  before_action :set_newsletter, only: [:show, :edit, :update, :destroy, :send_now]
  before_action :set_templates, only: [:new, :create, :edit, :update]
  before_action :check_editable_or_deletable, only: [:edit, :update, :destroy]
  #filter

  def index
    @q = Newsletter.ransack(params[:q], auth_object: 'own')
    @newsletters = @q.result.paginate(:page => params[:page], :per_page => 10)
  end


  def search
    Newsletter.load_custom_attributes
    @attributes = Hash.new()

    Newsletter.columns_hash.slice('name', 'subject', 'created_at', 'from_name', 'reply_email').each do |k,v|
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
    @newsletter.creator = current_user
    
    respond_to do |format|
      if @newsletter.save
        if @newsletter.template.present?
          profile = @newsletter.template.profile
          @newsletter.profiles = []
          @newsletter.profiles << profile
        end
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
    profile_emails_was = @newsletter.newsletter_emails.from_profile.map(&:emails).flatten
    sample_emails_was  = @newsletter.newsletter_emails.from_sample.map(&:emails).flatten.first
    contact_emails_was = @newsletter.newsletter_emails.from_contacts.map(&:emails).flatten.first

    respond_to do |format|
      if @newsletter.update(newsletter_params)
        if @newsletter.previous_changes.keys.include?("template_id")

          if @newsletter.template.present?
            profile = @newsletter.template.profile
            @newsletter.profiles = []
            @newsletter.profiles << profile
          end
          @newsletter.email_service.add_profile_members_to_list
          @newsletter.email_service.delete_members_from_list(profile_emails_was.first.split(","))
        end

        sample_emails_is = @newsletter.newsletter_emails.from_sample.map(&:emails).flatten.first
        if sample_emails_is != sample_emails_was
          @newsletter.email_service.delete_member_from_list(sample_emails_was) if sample_emails_was
          @newsletter.email_service.add_member_to_list(sample_emails_is) if sample_emails_is
        end
        
        contact_emails_is = @newsletter.newsletter_emails.from_contacts.map(&:emails).flatten.first
        if contact_emails_is != contact_emails_was
          @newsletter.email_service.delete_member_from_list(contact_emails_was) if contact_emails_was
          @newsletter.email_service.add_member_to_list(contact_emails_is) if contact_emails_is
        end
        
        @newsletter.email_service.update_campaign
        @newsletter.email_service.update_content

        # @newsletter.email_service.delete_members_from_list(emails_was - @newsletter.all_emails_arr)
        # @newsletter.email_service.add_members_to_list1(@newsletter.all_emails_arr - emails_was)
        
        format.html { redirect_to @newsletter, notice: t("controller.shared.flash.update.notice", model: pick_model_from_locale(:newsletter)) }
        format.json { render :show, status: :ok, location: @newsletter }
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
          render :edit 
        }
        format.json { render json: @newsletter.errors, status: t("controller.shared.flash.update.status") }
      end
    end
  end

  def destroy
    @newsletter.destroy

    respond_to do |format|
      format.html { redirect_to newsletters_url, notice: t("controller.shared.flash.destroy.notice", model: pick_model_from_locale(:newsletter)) }
      format.json { head :no_content }
    end
  end

  def send_now
    unless @newsletter.all_emails_arr.any?
      return redirect_to newsletters_path, notice: t('controller.newsletter.add_contacts')
    end 
      
    email_service = @newsletter.email_service
    checklist_fail = email_service.checklist_campaign
    if checklist_fail
      flash[:notice] = checklist_fail
      return redirect_to newsletters_path 
    end
    if email_service.members_in_list.count < 0
      return redirect_to newsletters_path, notice: t('controller.newsletter.not_imported')
    end

    email_service.update_content
    if email_service.send_campaign
      @newsletter.mark_sent
      return redirect_to newsletters_path, notice: t('controller.newsletter.send_successful')
    else
      return redirect_to newsletters_path, notice: t('controller.newsletter.not_imported')
    end
    
  end

  private

    def set_newsletter
      @newsletter = Newsletter.where(id: params[:id]).first
      unless @newsletter
        return redirect_to newsletters_url, notice: t('controller.newsletter.not_found')
      end
    end

    def newsletter_params
      params.require(:newsletter).permit(:campaign_id, :template_id, :name, :subject, :from_name, :from_address, 
        :reply_email, :created_by, :updated_by, :bcc_email, :cc_email, :send_at, :scheduled_at, :company_id,
        :auto_response, :profile_ids => [], :newsletter_emails_attributes => [ :emails, :sample, :from_contacts, :id ])
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
