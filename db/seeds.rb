# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Create admin user
admin_user = User.find_by(email: 'admin@daisypanel.com')

if admin_user.nil?
  admin_user = User.create_admin('admin@daisypanel.com', 'password123')
  puts "Admin user created: #{admin_user.email}"
else
  puts "Admin user already exists: #{admin_user.email}"
end
