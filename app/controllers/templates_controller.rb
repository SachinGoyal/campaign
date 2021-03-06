
class TemplatesController < ApplicationController
  
  layout 'dashboard' 

  #filter
  before_action :authenticate_user!  
  load_and_authorize_resource 
  before_action :set_template, only: [:show, :edit, :update, :destroy]
  #filter

  # GET /templates
  # GET /templates.json
  def index
    @q = Template.ransack(params[:q])
    @templates = @q.result.page(params[:page]).paginate(:page => params[:page], :per_page => 10)
  end

  def search
    Template.load_custom_attributes
    @attributes = Hash.new()

    Template.columns_hash.slice('name', 'content', 'created_at').each do |k,v|
      @attributes[k] = {value: k, type: v.type.to_s, association: nil}
    end

    @q  = Template.search(params[:q])
    @templates = @q.result.page(params[:page]).paginate(:page => params[:page], :per_page => 10)
    @q.build_condition    
  end

  # GET /templates/1
  # GET /templates/1.json
  def show
  end

  #PREVIEW Template
  def preview
    @template = Template.find(params[:id])
  end

  # GET /templates/new
  def new
    @template = Template.new
    @template.content = " "
  end

  def copy
    template = Template.find(params[:template_id]).dup
    template.name = "#{template.name}_#{(Time.zone.now.to_f * 10).to_i.to_s}" #'_copy'
    if  template.save
      respond_to do |format|
        format.html { redirect_to templates_url, notice: t("controller.shared.copy.success") }
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        format.html { redirect_to templates_url, notice: template.errors.full_messages.join(", ") }
        format.json { head :no_content }
      end
    end
  end 

  # GET /templates/1/edit
  def edit
  end

  def edit_all
    Template.edit_all(params[:group_ids], params[:get_action])  
    @templates = Template.all.paginate(:page => params[:page], :per_page => 10)
    action = params[:get_action].strip.capitalize
    @message = updateable_messages(action)
  end

  # POST /templates
  # POST /templates.json
  def create
    @template = Template.new(template_params)

    respond_to do |format|
      if @template.save
        format.html { redirect_to @template, notice: t("controller.shared.flash.create.notice", model: pick_model_from_locale(:template)) }
        format.json { render :show, status: :created, location: @template }
      else
        format.html { render :new }
        format.json { render json: @template.errors, status: t("controller.shared.flash.create.status") }
      end
    end
  end

  # PATCH/PUT /templates/1
  # PATCH/PUT /templates/1.json
  def update
    profile_id_was = @template.profile_id
    if params[:template][:status] and ActiveRecord::Type::Boolean.new.type_cast_from_user(params[:template][:status]) != @template.status and @template.newsletters.any?
      return redirect_to edit_template_path(@template), notice: t('activerecord.errors.models.template.attributes.base.associated_newsletter')
    end

    respond_to do |format|
      if @template.update(template_params)
        if @template.profile_id != profile_id_was
          @template.newsletters.unsent.each do |newsletter|
            newsletter_email = newsletter.newsletter_emails.from_profile.first
            newsletter.email_service.delete_members_from_list(newsletter_email.emails.split(","))

            profile = newsletter.template.profile
            newsletter.profiles = []
            newsletter.profiles << profile

            newsletter.email_service.add_profile_members_to_list
          end
        end
        format.html { redirect_to  @template, notice: t("controller.shared.flash.update.notice", model: pick_model_from_locale(:template)) }
        format.json { render :show, status: :ok, location: @template }
      else
        format.html { render :edit }
        format.json { render json: @template.errors, status: t("controller.shared.flash.update.status") }
      end
    end
  end

  # DELETE /templates/1
  # DELETE /templates/1.json
  def destroy
    if @template.destroy
      respond_to do |format|
        format.html { redirect_to templates_url, notice: t("controller.shared.flash.destroy.notice", model: pick_model_from_locale(:template)) }
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        format.html { redirect_to templates_url, notice: @template.errors.full_messages.join(", ") }
        format.json { head :no_content }
      end  
    end
  end

  private
    def set_template
      @template = Template.find(params[:id])
    end

    def template_params
      params.require(:template).permit(:user_id, :name,:profile_id, :content, :status, :created_by, :updated_by)
    end

    def updateable_messages(action)
      case action
        when 'Delete'
          t("controller.shared.flash.edit_all.notice.delete_all", model: pick_model_from_locale(:template))
        when 'Disable'
          t("controller.profile.disable_all", model: pick_model_from_locale(:profile))
        else
          t("controller.shared.flash.edit_all.notice.update_all", model: pick_model_from_locale(:profile))
      end
    end
end
