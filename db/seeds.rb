# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Role.create(:name => 'admin')
User.create(:role_id =>1 ,:username => 'sachin52',:email => 'goyalsachin52@gmail.com',:password => 'sachin@123',:password_confirmation => 'sachin@123')
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


# p "Data Functions"
# Function.destroy_all
# ActiveRecord::Base.connection.reset_pk_sequence!('functions')
# File.open(File.expand_path('data/es/functions.txt', RUTA)) do |file|
#   file.each_line do |line|
#     controller, action, agroup = line.strip.split(';')
#       function = Function.new
#       function.controller = controller.strip
#       function.action = action.strip
#       function.agroup = agroup.strip
#       function.save
#   end
# end


# Function.destroy_all
# File.open(functions.txt) do |file|
# 	