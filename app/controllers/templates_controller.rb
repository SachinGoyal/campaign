class TemplatesController < ApplicationController
  
  layout 'dashboard' # set custom layout 
  
  load_and_authorize_resource #cancan

  #filter
  before_action :authenticate_user!
  before_action :set_template, only: [:show, :edit, :update, :destroy]
  #filter

  # GET /templates
  # GET /templates.json
  def index
    @q = Template.ransack(params[:q])
    @templates = @q.result(distinct: true).page(params[:page]).paginate(:page => params[:page], :per_page => 10)
  end

  def search
    @attributes = Hash.new()

    User.columns_hash.slice('name', 'content', 'created_at').each do |k,v|
      @attributes[k] = {value: k, type: v.type.to_s, association: nil}
    end
    @q  = Template.search(params[:q])
    @templates = @q.result(distinct: true).page(params[:page]).paginate(:page => params[:page], :per_page => 10)
    @q.build_condition    
  end

  # GET /templates/1
  # GET /templates/1.json
  def show
  end

  # GET /templates/new
  def new
    @template = Template.new
  end

  def copy
    begin
      template = Template.find(params[:template_id]).dup
      template.name = template.name + '_copy'
      template.save
      respond_to do |format|
        format.html { redirect_to templates_url, notice: 'Template was successfully copied.' }
        format.json { head :no_content }
      end
    rescue 
      respond_to do |format|
        format.html { redirect_to templates_url, notice: 'Operation failed' }
        format.json { head :no_content }
      end
    end
  end 

  # GET /templates/1/edit
  def edit
  end

  def edit_all
    Template.edit_all(params[:group_ids], params[:get_action])  
    @templates = Template.all
    action = params[:get_action].strip.capitalize
    @message = updateable_messages(action)
  end

  # POST /templates
  # POST /templates.json
  def create
    @template = Template.new(template_params)

    respond_to do |format|
      if @template.save
        format.html { redirect_to @template, notice: 'Template was successfully created.' }
        format.json { render :show, status: :created, location: @template }
      else
        format.html { render :new }
        format.json { render json: @template.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /templates/1
  # PATCH/PUT /templates/1.json
  def update
    respond_to do |format|
      if @template.update(template_params)
        format.html { redirect_to  @template, notice: 'Template was successfully updated.' }
        format.json { render :show, status: :ok, location: @template }
      else
        format.html { render :edit }
        format.json { render json: @template.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /templates/1
  # DELETE /templates/1.json
  def destroy
    @template.destroy
    respond_to do |format|
      format.html { redirect_to templates_url, notice: 'Template was successfully destroyed.' }
      format.json { head :no_content }
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
          "Templates deleted successfully. Templates with associated data could not be deleted."
        else
          "Templates updated successfully."
      end

    end
end
