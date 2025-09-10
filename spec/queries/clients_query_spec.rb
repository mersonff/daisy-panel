require 'rails_helper'

RSpec.describe ClientsQuery do
  let(:user) { create(:user) }
  let!(:client1) { create(:client, user: user, name: 'João Silva', state: 'SP') }
  let!(:client2) { create(:client, user: user, name: 'Maria Santos', state: 'RJ') }
  let!(:client3) { create(:client, user: user, name: 'Pedro Oliveira', state: 'SP') }

  subject { described_class.new(user.clients) }

  describe '#call' do
    context 'without any filters' do
      it 'returns all clients ordered by name' do
        result = subject.call({})
        expect(result.to_a).to eq([ client1, client2, client3 ])
      end
    end

    context 'with search filters' do
      context 'when searching by name' do
        it 'filters clients by name' do
          params = { search: 'João', search_type: 'name' }
          result = subject.call(params)
          expect(result).to include(client1)
          expect(result).to_not include(client2, client3)
        end

        it 'is case insensitive' do
          params = { search: 'joão', search_type: 'name' }
          result = subject.call(params)
          expect(result).to include(client1)
        end
      end

      context 'when searching by CPF' do
        it 'filters clients by CPF' do
          params = { search: client2.cpf, search_type: 'cpf' }
          result = subject.call(params)
          expect(result).to include(client2)
          expect(result).to_not include(client1, client3)
        end

        it 'works with formatted CPF' do
          formatted_cpf = client2.cpf.gsub(/(\d{3})(\d{3})(\d{3})(\d{2})/, '\1.\2.\3-\4')
          params = { search: formatted_cpf, search_type: 'cpf' }
          result = subject.call(params)
          expect(result).to include(client2)
        end
      end

      context 'when searching by phone' do
        it 'filters clients by phone' do
          params = { search: client3.phone, search_type: 'phone' }
          result = subject.call(params)
          expect(result).to include(client3)
          expect(result).to_not include(client1, client2)
        end
      end

      context 'when doing general search' do
        it 'searches across all fields when no search_type specified' do
          params = { search: client1.name }
          result = subject.call(params)
          expect(result).to include(client1)
        end

        it 'finds results in any field' do
          # Busca por CPF sem especificar tipo
          params = { search: client2.cpf }
          result = subject.call(params)
          expect(result).to include(client2)
        end
      end
    end

    context 'with sorting' do
      before do
        # Ajustando as datas para teste de ordenação
        client1.update(created_at: 3.days.ago)
        client2.update(created_at: 1.day.ago)
        client3.update(created_at: 2.days.ago)
      end

      it 'sorts by name ascending' do
        params = { sort: 'name_asc' }
        result = subject.call(params)
        names = result.pluck(:name)
        expect(names).to eq([ 'JOÃO SILVA', 'MARIA SANTOS', 'PEDRO OLIVEIRA' ])
      end

      it 'sorts by name descending' do
        params = { sort: 'name_desc' }
        result = subject.call(params)
        names = result.pluck(:name)
        expect(names).to eq([ 'PEDRO OLIVEIRA', 'MARIA SANTOS', 'JOÃO SILVA' ])
      end

      it 'sorts by state ascending' do
        params = { sort: 'state_asc' }
        result = subject.call(params)
        states = result.pluck(:state)
        expect(states).to eq([ 'RJ', 'SP', 'SP' ])
      end

      it 'sorts by state descending' do
        params = { sort: 'state_desc' }
        result = subject.call(params)
        states = result.pluck(:state)
        expect(states).to eq([ 'SP', 'SP', 'RJ' ])
      end

      it 'sorts by created_at ascending (oldest first)' do
        params = { sort: 'created_at_asc' }
        result = subject.call(params)
        expect(result.first).to eq(client1) # 3 days ago
        expect(result.last).to eq(client2)  # 1 day ago
      end

      it 'sorts by created_at descending (newest first)' do
        params = { sort: 'created_at_desc' }
        result = subject.call(params)
        expect(result.first).to eq(client2) # 1 day ago
        expect(result.last).to eq(client1)  # 3 days ago
      end

      it 'defaults to name ascending when sort param is invalid' do
        params = { sort: 'invalid_sort' }
        result = subject.call(params)
        names = result.pluck(:name)
        expect(names).to eq([ 'JOÃO SILVA', 'MARIA SANTOS', 'PEDRO OLIVEIRA' ])
      end
    end

    context 'combining search and sort' do
      it 'applies both search and sort filters' do
        params = {
          search: 'Silva',
          search_type: 'name',
          sort: 'name_desc'
        }
        result = subject.call(params)
        expect(result).to include(client1)
        expect(result).to_not include(client2, client3)
      end
    end
  end

  describe 'private methods' do
    describe '#apply_search' do
      it 'returns original scope when no search term provided' do
        result = subject.send(:apply_search, user.clients, {})
        expect(result.count).to eq(3)
      end

      it 'returns original scope when search term is blank' do
        result = subject.send(:apply_search, user.clients, { search: '' })
        expect(result.count).to eq(3)
      end
    end

    describe '#apply_sorting' do
      it 'returns scope ordered by name when no sort param provided' do
        result = subject.send(:apply_sorting, user.clients, {})
        expect(result.to_sql).to include('ORDER BY')
      end
    end
  end
end
