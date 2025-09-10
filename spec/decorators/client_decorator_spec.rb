require 'rails_helper'

RSpec.describe ClientDecorator, type: :decorator do
  let(:client) do
    build(:client,
      cpf: '12345678901',
      address: 'Rua das Flores, 123',
      city: 'São Paulo',
      state: 'SP',
      cep: '01234-567',
      phone: '(11) 99999-9999'
    )
  end
  let(:decorator) { described_class.new(client) }

  describe '#formatted_cpf' do
    it 'formats CPF with dots and dash' do
      expect(decorator.formatted_cpf).to eq('123.456.789-01')
    end

    context 'with different CPF format' do
      let(:client) { build(:client, cpf: '98765432100') }

      it 'formats correctly' do
        expect(decorator.formatted_cpf).to eq('987.654.321-00')
      end
    end
  end

  describe '#full_address' do
    it 'combines address, city, state and cep' do
      expected = 'Rua das Flores, 123, São Paulo, SP, 01234-567'
      expect(decorator.full_address).to eq(expected)
    end
  end

  describe '#google_maps_url' do
    it 'generates Google Maps URL with encoded address' do
      expected = 'https://maps.google.com/?q=Rua+das+Flores,+123,+São+Paulo,+SP,+01234-567'
      expect(decorator.google_maps_url).to eq(expected)
    end

    context 'with special characters in address' do
      let(:client) { build(:client, address: 'Av. Paulista, 1000', city: 'São Paulo') }

      it 'encodes spaces correctly' do
        expect(decorator.google_maps_url).to include('Av.+Paulista,+1000,+São+Paulo')
      end
    end
  end

  describe '#phone_link' do
    it 'generates tel link with clean phone number' do
      expect(decorator.phone_link).to eq('tel:11999999999')
    end

    context 'with phone in different format' do
      let(:client) { build(:client, phone: '11 9 9999-9999') }

      it 'removes all non-digit characters' do
        expect(decorator.phone_link).to eq('tel:11999999999')
      end
    end
  end

  describe '#whatsapp_link' do
    it 'generates WhatsApp link with clean phone number' do
      expect(decorator.whatsapp_link).to eq('https://wa.me/11999999999')
    end

    context 'with international format' do
      let(:client) { build(:client, phone: '+55 (11) 99999-9999') }

      it 'removes all formatting' do
        expect(decorator.whatsapp_link).to eq('https://wa.me/5511999999999')
      end
    end
  end

  describe '#method_missing' do
    it 'delegates unknown methods to the client object' do
      expect(decorator.name).to eq(client.name)
      expect(decorator.address).to eq(client.address)
    end

    it 'raises NoMethodError for methods that do not exist on client' do
      expect { decorator.non_existent_method }.to raise_error(NoMethodError)
    end
  end

  describe '#respond_to_missing?' do
    it 'returns true for methods that exist on client' do
      expect(decorator.respond_to?(:name)).to be_truthy
      expect(decorator.respond_to?(:address)).to be_truthy
    end

    it 'returns false for methods that do not exist on client' do
      expect(decorator.respond_to?(:non_existent_method)).to be_falsey
    end
  end

  describe 'delegation behavior' do
    it 'allows access to all client attributes through decorator' do
      expect(decorator.id).to eq(client.id)
      expect(decorator.created_at).to eq(client.created_at)
      expect(decorator.updated_at).to eq(client.updated_at)
    end

    it 'allows calling client methods through decorator' do
      expect(decorator.valid?).to eq(client.valid?)
    end
  end
end
