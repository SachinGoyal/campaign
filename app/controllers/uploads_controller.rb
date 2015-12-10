class UploadsController < ApplicationController
  protect_from_forgery except: :create
 
  def create
    @template_image = TemplateImageUploader.new
    @template_image.store!(params[:template_image][:image])
    respond_to do |format|
      format.json { render :json => { url: (URI.parse(root_url) + @template_image.url).to_s } }
    end
  end
end