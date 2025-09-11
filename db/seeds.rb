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

# Create sample appointments for testing
if admin_user.appointments.count < 10
  puts "Creating sample appointments for testing..."

  # Lista de tipos de compromissos para variar os nomes
  appointment_types = [
    "Reunião com cliente",
    "Consulta médica",
    "Apresentação do projeto",
    "Call de alinhamento",
    "Workshop de treinamento",
    "Entrevista técnica",
    "Planejamento estratégico",
    "Review de código",
    "Demo do produto",
    "Sessão de feedback",
    "Reunião de vendas",
    "Acompanhamento mensal",
    "Brainstorming de ideias",
    "Avaliação de desempenho",
    "Treinamento interno"
  ]

  # Criar appointments passados (últimos 7 dias)
  5.times do |i|
    appointment_type = appointment_types.sample
    start_time = rand(1..7).days.ago.beginning_of_day + rand(8..17).hours + rand(0..3).minutes * 15
    end_time = start_time + [ 30.minutes, 1.hour, 1.5.hours, 2.hours ].sample

    admin_user.appointments.create!(
      name: "#{appointment_type} #{i + 1}",
      start_time: start_time,
      end_time: end_time
    )

    puts "Created past appointment: #{appointment_type} #{i + 1}"
  end

  # Criar appointment em andamento (agora)
  now = Time.current
  ongoing_start = now - 30.minutes
  ongoing_end = now + 30.minutes

  admin_user.appointments.create!(
    name: "Reunião importante em andamento",
    start_time: ongoing_start,
    end_time: ongoing_end
  )
  puts "Created ongoing appointment: Reunião importante em andamento"

  # Criar appointments futuros (próximos 30 dias) - usando intervalos sequenciais para evitar conflitos
  10.times do |i|
    appointment_type = appointment_types.sample
    # Usar dias sequenciais e horários específicos para evitar conflitos
    base_day = (i + 2).days.from_now.beginning_of_day
    start_time = base_day + (9 + (i % 8)).hours # Varia entre 9h e 16h
    end_time = start_time + [ 1.hour, 1.5.hours, 2.hours ].sample

    admin_user.appointments.create!(
      name: "#{appointment_type} #{i + 1}",
      start_time: start_time,
      end_time: end_time
    )

    puts "Created future appointment: #{appointment_type} #{i + 1}"
  end

  # Criar alguns appointments com duração específica para demonstrar diferentes cenários
  # Appointment de dia inteiro - usando data específica distante
  specific_date = 3.weeks.from_now.beginning_of_week + 5.days # Uma sexta-feira específica
  full_day = admin_user.appointments.new(
    name: "Workshop de treinamento - Dia inteiro",
    start_time: specific_date + 9.hours,
    end_time: specific_date + 18.hours
  )
  full_day.save!(validate: false)
  puts "Created full-day appointment: Workshop de treinamento - Dia inteiro"

  # Appointment de reunião rápida - usando horário bem cedo em data específica
  standup_date = 4.weeks.from_now.beginning_of_week + 1.day # Uma segunda-feira específica
  standup = admin_user.appointments.new(
    name: "Daily standup",
    start_time: standup_date + 8.hours,
    end_time: standup_date + 8.hours + 15.minutes
  )
  standup.save!(validate: false)
  puts "Created quick appointment: Daily standup"

  # Appointment de apresentação importante - usando data bem distante
  presentation_date = 6.weeks.from_now.beginning_of_week + 3.days # Uma quarta-feira específica
  presentation = admin_user.appointments.new(
    name: "Apresentação para investidores",
    start_time: presentation_date + 14.hours,
    end_time: presentation_date + 16.hours
  )
  presentation.save!(validate: false)
  puts "Created important appointment: Apresentação para investidores"

  puts "Sample appointments created successfully! Total: #{admin_user.appointments.count}"
  puts "  - Past: #{admin_user.appointments.past.count}"
  puts "  - Ongoing: #{admin_user.appointments.ongoing.count}"
  puts "  - Upcoming: #{admin_user.appointments.upcoming.count}"
else
  puts "Sample appointments already exist. Total: #{admin_user.appointments.count}"
  puts "  - Past: #{admin_user.appointments.past.count}"
  puts "  - Ongoing: #{admin_user.appointments.ongoing.count}"
  puts "  - Upcoming: #{admin_user.appointments.upcoming.count}"
end
