class ContactImportsController < ApplicationController
  def new
    @contact_import = ContactImport.new
  end

  def create 
    @contact_import = ContactImport.new(params[:contact_import])    
    @profile = Profile.find(params[:contact_import][:profile_id]) unless params[:contact_import][:profile_id].blank?
    @contact_import.save
    @q  = Contact.search(params[:q])
    @q.sorts = 'id desc' if @q.sorts.empty?
    @contacts = @q.result(distinct: true).page(params[:page]).paginate(:page => params[:page], :per_page => 10)
    @q.build_condition    

    render 'create.js.erb'
  end

  def search
  end
end
