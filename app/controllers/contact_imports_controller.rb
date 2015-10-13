class ContactImportsController < ApplicationController
  def new
    @contact_import = ContactImport.new
  end

  def create    
    @contact_import = ContactImport.new(params[:contact_import])    
    @contact_import.save
    render 'create.js.erb'
  end
end
