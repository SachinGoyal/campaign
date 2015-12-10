class AddTemplateImagesToTemplates < ActiveRecord::Migration
  def change
    add_column :templates, :template_images, :json
  end
end
