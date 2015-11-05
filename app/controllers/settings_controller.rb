class SettingsController < ApplicationController 

  layout 'dashboard' # set custom layout 

  load_and_authorize_resource #cancan

  #filter
  before_action :authenticate_user!
  before_action :set_setting, only: [:show, :edit, :update]
  #filter


  # GET /settings/1
  # GET /settings/1.json
  def show
  end


  # GET /settings/1/edit
  def edit
  end

  

  # PATCH/PUT /settings/1
  # PATCH/PUT /settings/1.json
  def update
    respond_to do |format|
      if @setting.update(setting_params)
        format.html { redirect_to @setting, notice: 'Setting was successfully updated.' }
        format.json { render :show, status: :ok, location: @setting }
      else
        format.html { render :edit }
        format.json { render json: @setting.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_setting
      @setting = Setting.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def setting_params
      params.require(:setting).permit( :site_title,:free_emails, :admin_email, :admin_footer_content)
    end
end
