class CampaignsController < ApplicationController

  before_action :authenticate_user!
  load_and_authorize_resource #cancan
  layout 'dashboard' # set custom layout 
  
  
  #filter
  before_action :set_campaign, only: [:show, :edit, :update, :destroy]
  # before_action :filter_reports, only: [:reports, :stats]
  before_filter :get_translations, only: [:stats]
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
    @total_emails = 0
    @emails_sent = 0
    @campaigns = Campaign.all
    @newsletter = Newsletter.find(params[:newsletter_id]) if params[:newsletter_id] and !params[:newsletter_id].blank?
    if params[:campaign_id] and !params[:campaign_id].blank?
      @campaign = Campaign.find(params[:campaign_id])
    end
    if @newsletter
      @campaign = @newsletter.campaign
    end

      columns = ['opens_total','unique_opens','clicks_total','unique_clicks','unique_subscriber_clicks','hard_bounces','soft_bounces','unsubscribed','forwards_count','forwards_opens', 'abuse_reports','emails_sent']
      if @newsletter
        es = @newsletter.email_service
        if @newsletter.sent?  && es.present? 
          email_stat = es.get_stats
          email_stat = email_stat.attributes.extract!(*columns).values
          email_stat.map! { |x| x || 0 }
          @total_emails = @newsletter.all_emails_arr.count
          @emails_sent = email_stat.pop
        end
      else
        if @campaign
          array = []        
          @campaign.newsletters.each do |newsletter|
            es = newsletter.email_service
            if newsletter.sent? && es.present? 
              email_stat = es.get_stats
              email_stat = email_stat.attributes.extract!(*columns).values
              email_stat.map! { |x| x || 0 }
              @total_emails = newsletter.all_emails_arr.count
              array << email_stat
            end
          end
          email_stat = array.transpose.map {|x| x.reduce(:+)}
          @emails_sent = email_stat.pop
        end
      end
      @data = email_stat
  end

  def stats
    @total_emails = 0
    @emails_sent = 0
    @campaigns = Campaign.all
    @newsletter = Newsletter.find(params[:newsletter_id]) if params[:newsletter_id] and !params[:newsletter_id].blank?
    if params[:campaign_id] and !params[:campaign_id].blank?
      @campaign = Campaign.find(params[:campaign_id])
    end
    if @newsletter
      @campaign = @newsletter.campaign
    end

      columns = ['opens_total','unique_opens','clicks_total','unique_clicks','unique_subscriber_clicks','hard_bounces','soft_bounces','unsubscribed','forwards_count','forwards_opens', 'abuse_reports','emails_sent']
      if @newsletter
        es = @newsletter.email_service
        if @newsletter.sent?  && es.present? 
          email_stat = es.get_stats
          email_stat = email_stat.attributes.extract!(*columns).values
          email_stat.map! { |x| x || 0 }
          @total_emails = @newsletter.all_emails_arr.count
          @emails_sent = email_stat.pop
        end
      else
        if @campaign
          array = []        
          @campaign.newsletters.each do |newsletter|
            es = newsletter.email_service
            if newsletter.sent? && es.present? 
              email_stat = es.get_stats
              email_stat = email_stat.attributes.extract!(*columns).values
              email_stat.map! { |x| x || 0 }
              @total_emails = newsletter.all_emails_arr.count
              array << email_stat
            end
          end
          email_stat = array.transpose.map {|x| x.reduce(:+)}
          @emails_sent = email_stat.pop
        end
      end
      @data = email_stat
  end

  def select_newsletter
    @newsletters = Campaign.find(params[:campaign_id]).try(:newsletters).try(:sent)
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
        format.html { redirect_to campaigns_url, notice: t("controller.shared.flash.destroy.notice",model: pick_model_from_locale(:campaign)) }
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

    def filter_reports
      report = params[:report]
      @campaign_id = (report and report.has_key?('campaign_id') ? report[:campaign_id] : '')
      @newsletter_id = (report and report.has_key?('newsletter_id') ? report[:newsletter_id] : '')
      @newsletters = Newsletter.where(campaign_id: @campaign_id) #if report.present? && report[:newsletter_id].present?
    end

    def get_translations
          @stats = [t('activerecord.attributes.email_service.opens_total') ,
        t('activerecord.attributes.email_service.unique_opens') ,
        t('activerecord.attributes.email_service.clicks_total'),
        t('activerecord.attributes.email_service.unique_clicks'),
        t('activerecord.attributes.email_service.unique_subscriber_clicks'),
        t('activerecord.attributes.email_service.hard_bounces'),
        t('activerecord.attributes.email_service.soft_bounces'),
        t('activerecord.attributes.email_service.unsubscribed'),
        t('activerecord.attributes.email_service.forwards_count'),
        t('activerecord.attributes.email_service.forwards_opens'),
        t('activerecord.attributes.email_service.abuse_reports')]
    end

end
