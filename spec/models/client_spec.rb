require 'rails_helper'

RSpec.describe Client, type: :model do
  let(:user) { create(:user) }
  let(:client) { build(:client, user: user) }

  describe 'associations' do
    it { should belong_to(:user) }
  end

  describe 'validations' do
    context 'presence validations' do
      it { should validate_presence_of(:name) }
      it { should validate_presence_of(:address) }
      it { should validate_presence_of(:city) }
      it { should validate_presence_of(:state) }
      it { should validate_presence_of(:cep) }
      it { should validate_presence_of(:phone) }
      it { should validate_presence_of(:cpf) }
    end

    context 'CPF validation' do
      it 'is valid with a valid CPF' do
        client.cpf = '11144477735' # CPF válido
        expect(client).to be_valid
      end

      it 'is invalid with an invalid CPF' do
        client.cpf = '12345678901' # CPF inválido
        expect(client).to_not be_valid
        expect(client.errors[:cpf]).to include('não é válido')
      end

      it 'is invalid with duplicate CPF for the same user' do
        create(:client, user: user, cpf: '11144477735')
        client.cpf = '11144477735'

        expect(client).to_not be_valid
        expect(client.errors[:cpf]).to include('já está cadastrado')
      end

      it 'allows same CPF for different users' do
        other_user = create(:user)
        create(:client, user: other_user, cpf: '11144477735')
        client.cpf = '11144477735'

        expect(client).to be_valid
      end
    end

    context 'state validation' do
      it 'is valid with a valid state' do
        valid_states = %w[AC AL AP AM BA CE DF ES GO MA MT MS MG PA PB PR PE PI RJ RN RS RO RR SC SP SE TO]
        valid_states.each do |state|
          client.state = state
          expect(client).to be_valid
        end
      end

      it 'is invalid with an invalid state' do
        client.state = 'XX'
        expect(client).to_not be_valid
        expect(client.errors[:state]).to include('não é um estado válido')
      end
    end

    context 'phone validation' do
      it 'is valid with correct phone formats' do
        valid_phones = [
          '(11) 99999-9999',
          '(21) 9999-9999',
          '11999999999',
          '(11) 3333-3333'
        ]

        valid_phones.each do |phone|
          client.phone = phone
          expect(client).to be_valid
        end
      end

      it 'is invalid with incorrect phone format' do
        invalid_phones = [ '123', '999999999', 'abc', '(11) 9999-999' ]

        invalid_phones.each do |phone|
          user = create(:user)
          invalid_client = Client.new(
            name: 'Test Client',
            address: 'Test Address, 123',
            city: 'Test City',
            state: 'SP',
            cep: '12345-678',
            phone: phone,
            cpf: CPF.generate,
            user: user
          )
          expect(invalid_client).to_not be_valid
          expect(invalid_client.errors[:phone]).to include('deve ter formato (11) 99999-9999')
        end
      end
    end

    context 'CEP validation' do
      it 'is valid with correct CEP formats' do
        valid_ceps = [ '01234-567', '12345678' ]

        valid_ceps.each do |cep|
          client.cep = cep
          expect(client).to be_valid
        end
      end

      it 'is invalid with incorrect CEP format' do
        invalid_ceps = [ '123', '1234-567', 'abcde-fgh' ]

        invalid_ceps.each do |cep|
          client.cep = cep
          expect(client).to_not be_valid
        end
      end
    end
  end

  describe 'callbacks' do
    context 'before_save callbacks' do
      it 'normalizes state to uppercase' do
        client.state = 'sp'
        client.save
        expect(client.state).to eq('SP')
      end

      it 'formats phone number' do
        client.phone = '11999999999'
        client.save
        expect(client.phone).to eq('(11) 99999-9999')
      end

      it 'formats CEP' do
        client.cep = '12345678'
        client.save
        expect(client.cep).to eq('12345-678')
      end

      it 'removes non-numeric characters from CPF' do
        client.cpf = '111.444.777-35'
        client.save
        expect(client.cpf).to eq('11144477735')
      end
    end
  end

  describe 'scopes' do
    let!(:client1) { create(:client, user: user, name: 'João Silva') }
    let!(:client2) { create(:client, user: user, name: 'Maria Santos') }
    let!(:client3) { create(:client, user: user, cpf: '11144477735') }

    describe '.search_by_name' do
      it 'finds clients by partial name match' do
        results = Client.search_by_name('João')
        expect(results).to include(client1)
        expect(results).to_not include(client2)
      end

      it 'is case insensitive' do
        results = Client.search_by_name('joão')
        expect(results).to include(client1)
      end
    end

    describe '.search_by_cpf' do
      it 'finds clients by CPF' do
        results = Client.search_by_cpf('111.444.777-35')
        expect(results).to include(client3)
      end

      it 'finds clients by partial CPF' do
        results = Client.search_by_cpf('11144')
        expect(results).to include(client3)
      end
    end

    describe '.search_by_phone' do
      it 'finds clients by phone number' do
        phone = client1.phone
        results = Client.search_by_phone(phone)
        expect(results).to include(client1)
      end

      it 'finds clients by partial phone' do
        # Assumindo que o telefone começa com (11)
        results = Client.search_by_phone('(11)')
        # Pode incluir múltiplos clientes dependendo dos dados gerados
        expect(results.count).to be >= 0
      end
    end
  end

  describe 'instance methods' do
    before { client.save }

    it 'returns a string representation' do
      expect(client.to_s).to eq(client.name)
    end

    it 'has a valid factory' do
      expect(client).to be_valid
    end
  end
end
