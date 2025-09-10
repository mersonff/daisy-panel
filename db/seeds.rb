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

# Create sample clients for testing pagination
if admin_user.clients.count < 25
  puts "Creating sample clients for testing..."

  # Configurar Faker para Brasil
  Faker::Config.locale = :'pt-BR'

  35.times do |index|
    client = admin_user.clients.create!(
      name: Faker::Name.name,
      cpf: Faker::IdNumber.brazilian_citizen_number(formatted: false),
      phone: Faker::PhoneNumber.cell_phone,
      address: "#{Faker::Address.street_name}, #{Faker::Address.building_number}",
      city: Faker::Address.city,
      state: Faker::Address.state_abbr,
      cep: Faker::Address.zip_code
    )

    puts "Created client: #{client.name} - #{client.city}/#{client.state}"
  end

  puts "Sample clients created successfully! Total: #{admin_user.clients.count}"
else
  puts "Sample clients already exist. Total: #{admin_user.clients.count}"
end
