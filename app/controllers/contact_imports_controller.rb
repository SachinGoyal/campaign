class ContactImportsController < ApplicationController
  def new
    @contact_import = ContactImport.new
  end

  def create
    # @contact_import = ContactImport.initialize_values(params[:contact_import])
    @contact_import = ContactImport.new(params[:contact_import])
    

    if @contact_import.save
      redirect_to profiles_path, notice: "Imported contacts successfully."
    else
      render json:  'create.js.erb'
    end
  end
end
