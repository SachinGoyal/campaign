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
    if params[:report].present?
      campaign_id = params[:report][:campaign_id]
      newsletter_id = params[:report][:newsletter_id]
      columns = ['opens_total','unique_opens','unique_opens','clicks_total','unique_clicks','unique_subscriber_clicks','hard_bounces','soft_bounces','unsubscribed','forwards_count','forwards_opens', 'emails_sent', 'abuse_reports']
      if newsletter_id.present?
        newsletter = Newsletter.find(newsletter_id)
       # email_stat = newsletter.email_service.get_stats
        email_stat = newsletter.email_service
        email_stat = email_stat.attributes.extract!(*columns).values
        email_stat.map! { |x| x || 0 }
      else
        if campaign_id.present?
          array = []
          campaign = Campaign.find(campaign_id)
          campaign.newsletters.each do |newsletter|
            if newsletter.email_service.present?
             # email_stat = newsletter.email_service.get_stats
              email_stat = newsletter.email_service
              email_stat = email_stat.attributes.extract!(*columns).values
              email_stat.map! { |x| x || 0 }
              array << email_stat
            end
          end
          email_stat = array.transpose.map {|x| x.reduce(:+)}
        end
      end
      @data = email_stat
    end
#    @data = [32,34,43,43,35,23,12,54,45,54,34,32 ]
    @campaign = Campaign.first
  end

  def stats
    if params[:report].present?
      campaign_id = params[:report][:campaign_id]
      newsletter_id = params[:report][:newsletter_id]
      columns = ['opens_total','unique_opens','unique_opens','clicks_total','unique_clicks','unique_subscriber_clicks','hard_bounces','soft_bounces','unsubscribed','forwards_count','forwards_opens', 'emails_sent', 'abuse_reports']
      if newsletter_id.present?
        newsletter = Newsletter.find(newsletter_id)
       # email_stat = newsletter.email_service.get_stats
        email_stat = newsletter.email_service
        email_stat = email_stat.attributes.extract!(*columns).values
        email_stat.map! { |x| x || 0 }
      else
        if campaign_id.present?
          array = []
          campaign = Campaign.find(campaign_id)
          campaign.newsletters.each do |newsletter|
            if newsletter.email_service.present?
             # email_stat = newsletter.email_service.get_stats
              email_stat = newsletter.email_service
              email_stat = email_stat.attributes.extract!(*columns).values
              email_stat.map! { |x| x || 0 }
              array << email_stat
            end
          end
          email_stat = array.transpose.map {|x| x.reduce(:+)}
        end
      end
      @data = email_stat
    end
#    @data = [32,34,43,43,35,23,12,54,45,54,34,32 ]
    @campaign = Campaign.first
    @stats = ["Open Total", "Unique Total", "Click Total", "Unique Click" , "Unique Subscriber Clicks", "Hard Bounces", "Soft Bounces", "Unsubscribed", "Forwards Count" , "Forwards Opens", "Emails Sent", "Abuse Reports"]
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
    @campaigns = Campaign.all.paginate(:page => params[:page], :per_page => 10)
    action = params[:get_action].strip.capitalize
    @message = updateable_messages(action)
  end

  # POST /campaigns
  # POST /campaigns.json
  def create
    @campaign = Campaign.new(campaign_params)
    respond_to do |format|
      if @campaign.save
        format.html { redirect_to @campaign, notice: t("controller.shared.flash.create.notice", model: pick_model_from_locale(:campaign)) }
        format.json { render :show, status: :created, location: @campaign }
      else
        format.html { render :new }
        format.json { render json: @campaign.errors, status: t("controller.shared.flash.create.status") }
      end
    end
  end

  # PATCH/PUT /campaigns/1
  # PATCH/PUT /campaigns/1.json
  def update
    respond_to do |format|
      if @campaign.update(campaign_params)
        format.html { redirect_to @campaign, notice: t("controller.shared.flash.update.notice",model: pick_model_from_locale(:campaign)) }
        format.json { render :show, status: :ok, location: @campaign }
      else
        format.html { render :edit }
        format.json { render json: @campaign.errors, status: t("controller.shared.flash.update.status") }
      end
    end
  end

  # DELETE /campaigns/1
  # DELETE /campaigns/1.json
  def destroy
    if @campaign.destroy
      respond_to do |format|
        format.html { redirect_to campaigns_url, notice: t("controller.shared.notice.destroy.notice",model: pick_model_from_locale(:campaign)) }
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
          t("controller.shared.flash.edit_all.notice.delete_all",model: pick_model_from_locale(:campaign))
        else
          t("controller.shared.flash.edit_all.notice.update_all",model: pick_model_from_locale(:campaign))
      end

    end
end
