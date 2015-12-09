class UploadsController < ApplicationController
  protect_from_forgery except: :create
 
  def create
    @template_image = TemplateImageUploader.new
    @template_image.store!(params[:template_image][:image])
    # binding.pry
    respond_to do |format|
      format.json { render :json => { url: @template_image.url } }
    end
  end
end