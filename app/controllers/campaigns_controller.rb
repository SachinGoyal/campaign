class CampaignsController < ApplicationController

  before_action :authenticate_user!
  load_and_authorize_resource #cancan
  layout 'dashboard' # set custom layout 
  
  
  #filter
  before_action :set_campaign, only: [:show, :edit, :update, :destroy]
  #filter
  
  # GET /campaigns
  # GET /campaigns.json
  def index
    @q = Campaign.ransack(params[:q])
    @campaigns = @q.result.paginate(:page => params[:page], :per_page => 10)
  end

  def search
    @attributes = Hash.new()

    Campaign.columns_hash.slice('name','created_at', 'status').each do |k,v|
      @attributes[k] = {value: k, type: v.type.to_s, association: nil}
    end

    @q  = Campaign.search(params[:q])
   # @q.sorts = 'id desc' if @q.sorts.empty?
    @campaigns = @q.result.page(params[:page]).paginate(:page => params[:page], :per_page => 10)
    @q.build_condition    
  end

  def reports
    @campaign = Campaign.first
  end

  def stats
    @campaign = Campaign.first
  end

  def select_newsletter
    begin
      @newsletters = Campaign.find(params[:campaign_id]).newsletters
    rescue
      @newsletters = nil
    end 
  end

  # GET /campaigns/1
  # GET /campaigns/1.json
  def show
  end

  # GET /campaigns/new
  def new
    @campaign = Campaign.new
  end

  # GET /campaigns/1/edit
  def edit
  end

  def edit_all
    Campaign.edit_all(params[:group_ids], params[:get_action])  
    @campaigns = Campaign.all
    action = params[:get_action].strip.capitalize
    @message = updateable_messages(action)
  end

  # POST /campaigns
  # POST /campaigns.json
  def create
    @campaign = Campaign.new(campaign_params)
    respond_to do |format|
      if @campaign.save
        format.html { redirect_to @campaign, notice: 'Campaign was successfully created.' }
        format.json { render :show, status: :created, location: @campaign }
      else
        format.html { render :new }
        format.json { render json: @campaign.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /campaigns/1
  # PATCH/PUT /campaigns/1.json
  def update
    respond_to do |format|
      if @campaign.update(campaign_params)
        format.html { redirect_to @campaign, notice: 'Campaign was successfully updated.' }
        format.json { render :show, status: :ok, location: @campaign }
      else
        format.html { render :edit }
        format.json { render json: @campaign.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /campaigns/1
  # DELETE /campaigns/1.json
  def destroy
    if @campaign.destroy
      respond_to do |format|
        format.html { redirect_to campaigns_url, notice: 'Campaign was successfully deleted.' }
        format.json { head :no_content }
      end
    else
        respond_to do |format|
        format.html { redirect_to campaigns_url, notice: @campaign.errors.full_messages.join(", ") }
        format.json { head :no_content }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_campaign
      @campaign = Campaign.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def campaign_params
      params.require(:campaign).permit(:user_id, :name, :description, :status, :created_by, :updated_by)
    end

    def updateable_messages(action)
      case action
        when 'Delete'
          "Campaigns deleted successfully. Campaigns with associated data could not be deleted."
        else
          "Campaigns updated successfully."
      end

    end
end
