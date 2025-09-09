require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    subject { build(:user) }

    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email).case_insensitive }
    it { should validate_presence_of(:password) }
    it { should validate_length_of(:password).is_at_least(6) }

    it 'has a valid factory' do
      expect(build(:user)).to be_valid
    end
  end

  describe 'devise modules' do
    it 'includes database_authenticatable' do
      expect(User.devise_modules).to include(:database_authenticatable)
    end

    it 'includes registerable' do
      expect(User.devise_modules).to include(:registerable)
    end

    it 'includes recoverable' do
      expect(User.devise_modules).to include(:recoverable)
    end

    it 'includes rememberable' do
      expect(User.devise_modules).to include(:rememberable)
    end

    it 'includes validatable' do
      expect(User.devise_modules).to include(:validatable)
    end
  end

  describe '.create_admin' do
    context 'when admin does not exist' do
      it 'creates an admin user' do
        expect { User.create_admin('admin@example.com', 'password123') }.to change { User.count }.by(1)
        
        admin = User.last
        expect(admin.email).to eq('admin@example.com')
      end

      it 'returns the created admin user' do
        admin = User.create_admin('admin@example.com', 'password123')
        expect(admin).to be_persisted
        expect(admin.email).to eq('admin@example.com')
      end
    end

    context 'when admin already exists' do
      before { create(:user, email: 'admin@example.com') }

      it 'raises an error for duplicate email' do
        expect { User.create_admin('admin@example.com', 'password123') }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end

  describe 'password validation' do
    it 'requires password confirmation to match' do
      user = build(:user, password: 'password123', password_confirmation: 'different')
      expect(user).not_to be_valid
      expect(user.errors[:password_confirmation]).to include("não é igual a Senha")
    end

    it 'accepts valid password confirmation' do
      user = build(:user, password: 'password123', password_confirmation: 'password123')
      expect(user).to be_valid
    end
  end

  describe 'email validation' do
    it 'accepts valid email formats' do
      valid_emails = %w[
        user@example.com
        test.email@domain.co.uk
        user+tag@example.org
      ]

      valid_emails.each do |email|
        user = build(:user, email: email)
        expect(user).to be_valid, "#{email} should be valid"
      end
    end

    it 'rejects invalid email formats' do
      invalid_emails = %w[
        plainaddress
        @missinglocalpart.com
      ]

      invalid_emails.each do |email|
        user = build(:user, email: email)
        expect(user).not_to be_valid, "#{email} should be invalid"
      end
    end

    it 'normalizes email to lowercase' do
      user = create(:user, email: 'USER@EXAMPLE.COM')
      expect(user.email).to eq('user@example.com')
    end
  end

  describe 'authentication' do
    let(:user) { create(:user, password: 'password123') }

    it 'authenticates with correct password' do
      expect(user.valid_password?('password123')).to be true
    end

    it 'does not authenticate with incorrect password' do
      expect(user.valid_password?('wrongpassword')).to be false
    end
  end
end
