module ApplicationHelper

  def link_to_remove_fields(name, f)
    f.hidden_field(:_destroy) + link_to_function(name, "remove_fields(this)")
  end
  
  def link_to_add_fields(name, f, association)
    new_object = f.object.class.reflect_on_association(association).klass.new
    fields = f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
      render(association.to_s.singularize + "_fields", :f => builder)
    end
    link_to_function(name, "add_fields(this, \"#{association}\", \"#{escape_javascript(fields)}\")")
  end

 # def link_to_add_fields(name, f, type)
 #    new_object = f.object.send "build_#{type}"
 #    id = "new_#{type}"
 #    fields = f.send("#{type}_fields", new_object, child_index: id) do |builder|
 #      render(type.to_s + "_fields", f: builder)
 #    end
 #    link_to(name, '#', class: "add_fields_fieldset", data: {id: id, fields: fields.gsub("\n", "")})
 #  end

  def link_to_add_condition_group(name, f, type) # relation one to one
    new_object = f.object.send "build_#{type}"
    id = "new_#{type}"
    fields = f.send("#{type}_fields", new_object, child_index: id) do |builder|
      render(type.to_s + "_fields", f: builder)
    end
    link_to(name, '#', class: "add_fields", data: {id: id, fields: fields.gsub("\n", "")})
  end

  def format_date(obj, field)
  	#obj.send(field).send(:strftime, "%d/%m/%y, %I:%M %p")
    l(obj.send(field), format: "%d/%m/%y, %I:%M %p")
  end

  def display_status(obj)
    obj.status ? t('frontend.shared.enabled') : t('frontend.shared.disabled') 
  end

  def pick_model_from_locale(model_name)
     I18n.backend.send(:translations)[I18n.locale][:activerecord][:models][model_name]
  end
end
