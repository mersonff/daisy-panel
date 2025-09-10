# frozen_string_literal: true

require "cpf_cnpj"

FactoryBot.define do
  factory :client do
    name { Faker::Name.name }
    address { "#{Faker::Address.street_address}, #{Faker::Address.building_number}" }
    city { Faker::Address.city }
    state { [ 'SP', 'RJ', 'MG', 'RS', 'PR', 'SC', 'BA', 'GO', 'PE', 'CE' ].sample }
    cep { Faker::Address.zip_code.gsub(/\D/, '').insert(5, '-') }
    phone { "(#{Faker::Number.number(digits: 2)}) #{Faker::Number.number(digits: 5)}-#{Faker::Number.number(digits: 4)}" }
    cpf { CPF.generate }
    user { association :user }

    trait :with_invalid_cpf do
      cpf { "123.456.789-00" }
    end
  end
end
