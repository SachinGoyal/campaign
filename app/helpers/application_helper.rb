module ApplicationHelper
 def link_to_add_fields(name, f, type)
    new_object = f.object.send "build_#{type}"
    id = "new_#{type}"
    fields = f.send("#{type}_fields", new_object, child_index: id) do |builder|
      render(type.to_s + "_fields", f: builder)
    end
    link_to(name, '#', class: "add_fields_fieldset", data: {id: id, fields: fields.gsub("\n", "")})
  end

  def link_to_add_condition_group(name, f, type) # relation one to one
    new_object = f.object.send "build_#{type}"
    id = "new_#{type}"
    fields = f.send("#{type}_fields", new_object, child_index: id) do |builder|
      render(type.to_s + "_fields", f: builder)
    end
    link_to(name, '#', class: "add_fields", data: {id: id, fields: fields.gsub("\n", "")})
  end

  def format_date(obj, field)
  	obj.send(field).send(:strftime, "%d/%m/%y, %I:%M %p")
    l(obj.send(field), format: "%d/%m/%y, %I:%M %p")
  end

  def display_status(obj)
    obj.status ? t('frontend.shared.enabled') : t('frontend.shared.disabled') 
  end
end
