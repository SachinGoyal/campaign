
Role.create(:name => 'admin')
Role.create(:name => 'company admin')
User.create(:role_id =>1 ,:username => 'admin',:email => 'goyalsachin52@gmail.com',:password => 'admin@123',:password_confirmation => 'sachin@123')

RUTA = File.dirname(__FILE__)
p "Data Functions"
Function.destroy_all
#ActiveRecord::Base.connection.reset_pk_sequence!('functions')
File.open(File.expand_path('data/es/functions.txt', RUTA)) do |file|
  file.each_line do |line|
    controller, action, agroup = line.strip.split(';')
      function = Function.new
      function.controller = controller.strip if controller.present?
      function.action = action.strip if action.present?
      function.agroup = agroup.strip if agroup.present?
      function.save
  end
end

# # user.add_role :admin
# Role.destroy_all
# #ActiveRecord::Base.connection.reset_pk_sequence!('roles')

# File.open(File.expand_path('data/es/role_base.txt', RUTA)) do |file|
#  file.each_line do |line|
#    name, is_base, is_agent, is_supervisor = line.strip.split(';')
#      role = Role.new
#      role.name = name.strip
#      role.is_base = is_base.strip
#      role.is_agent = is_agent.strip
#      role.is_supervisor = is_supervisor.strip
#      role.save
#  end
# end



# Function.destroy_all
# File.open(functions.txt) do |file|
# 	