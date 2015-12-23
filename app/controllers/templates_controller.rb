class TemplatesController < ApplicationController
  
  layout 'dashboard' # set custom layout 


  #filter
  before_action :authenticate_user!  
  load_and_authorize_resource #cancan
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
  end

  def copy
    template = Template.find(params[:template_id]).dup
    # if template.name.split('_').length > 1
    #   name = template.name.split('_')
    #   if name.last.length == 14 
    #     name.pop
    #   end
    #   name = name.join('_')
    # else
    #   name = template.name
    # end
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
    if params[:template][:status] and ActiveRecord::Type::Boolean.new.type_cast_from_user(params[:template][:status]) != @template.status and @template.newsletters.any?
      return redirect_to edit_template_path(@template), notice: t('activerecord.errors.models.template.attributes.base.associated_newsletter')
    end

    respond_to do |format|
      if @template.update(template_params)
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
    # Use callbacks to share common setup or constraints between actions.
    def set_template
      @template = Template.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def template_params
      params.require(:template).permit(:user_id, :name, :content, :status, :created_by, :updated_by)
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
