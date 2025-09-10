require 'rails_helper'

RSpec.describe ApplicationMailer, type: :mailer do
  describe 'default configuration' do
    it 'has the correct default from address' do
      expect(ApplicationMailer.default[:from]).to eq('from@example.com')
    end
  end

  describe 'inheritance' do
    it 'inherits from ActionMailer::Base' do
      expect(ApplicationMailer.superclass).to eq(ActionMailer::Base)
    end
  end

  describe 'basic functionality' do
    it 'can be instantiated' do
      expect { ApplicationMailer.new }.not_to raise_error
    end
  end
end
