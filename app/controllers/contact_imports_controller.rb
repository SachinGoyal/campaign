class ContactImportsController < ApplicationController
  def new
    @contact_import = ContactImport.new
  end

  def create    
    @contact_import = ContactImport.new(params[:contact_import])    
    @profile = Profile.find(params[:contact_import][:profile_id])
    @contact_import.save
    render 'create.js.erb'
  end
end
