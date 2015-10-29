class AttributesController < ApplicationController
  
  layout 'dashboard' # set custom layout 
  
  before_action :authenticate_user!
  load_and_authorize_resource #cancan

  #filter
  before_action :set_attribute, only: [:show, :edit, :update, :destroy]
  #filter
  

  # GET /attributes
  # GET /attributes.json
  def index    
    @q = Attribute.ransack(params[:q])
    @attributes = @q.result(distinct: true).paginate(:page => params[:page], :per_page => 10)
    respond_to do |format|
      format.html
      format.js { @attributes.to_json }
    end
  end
  
  # GET /attributes/1
  # GET /attributes/1.json
  def show
  end

  # GET /attributes/new
  def new
    @attribute = Attribute.new
  end

  # GET /attributes/1/edit
  def edit
  end

  # GET /profiles/edit_all
  def edit_all
    Attribute.edit_all(params[:group_ids], params[:get_action])
    @attributes = Attribute.all
    action = params[:get_action].strip.capitalize
    @message = updateable_messages(action)
  end

  # POST /attributes
  # POST /attributes.json
  def create
    @attribute = Attribute.new(attribute_params)

    respond_to do |format|
      if @attribute.save
        format.html { redirect_to @attribute, notice: 'Attribute was successfully created.' }
        format.json { render :show, status: :created, location: @attribute }
      else
        format.html { render :new }
        format.json { render json: @attribute.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /attributes/1
  # PATCH/PUT /attributes/1.json
  def update
    respond_to do |format|
      if @attribute.update(attribute_params)
        format.html { redirect_to @attribute, notice: 'Attribute was successfully updated.' }
        format.json { render :show, status: :ok, location: @attribute }
      else
        format.html { render :edit }
        format.json { render json: @attribute.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /attributes/1
  # DELETE /attributes/1.json
  def destroy
    respond_to do |format|
      if @attribute.destroy
        format.html { redirect_to attributes_url, notice: 'Attribute was successfully deleted.' }
        format.json { head :no_content }
      else
        format.html { redirect_to attributes_url, notice: @attribute.errors.full_messages.join(", ")}
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_attribute
      @attribute = Attribute.find(params[:id])
      unless @attribute
        return redirect_to attributes_path, :alert => "Could not find attribute"
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def attribute_params
      params.require(:attribute).permit(:company_id, :name, :description, :status)
    end

    def updateable_messages(action)
    case action
      when 'Delete'
        "Attributes deleted successfully."
      else
        "Attributes updated successfully."
    end

    end
end
