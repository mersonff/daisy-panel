require 'rails_helper'

RSpec.describe ApplicationJob, type: :job do
  describe 'job configuration' do
    it 'inherits from ActiveJob::Base' do
      expect(ApplicationJob.superclass).to eq(ActiveJob::Base)
    end
  end

  describe 'job behavior' do
    # Criamos uma job de teste para verificar o comportamento
    class TestJob < ApplicationJob
      def perform(value)
        value
      end
    end

    it 'can be enqueued' do
      expect {
        TestJob.perform_later('test')
      }.to have_enqueued_job(TestJob).with('test')
    end

    it 'can be performed' do
      job = TestJob.new
      expect(job.perform('test_value')).to eq('test_value')
    end
  end

  describe 'error handling configuration' do
    it 'has the correct superclass for error handling' do
      expect(ApplicationJob < ActiveJob::Base).to be_truthy
    end
  end
end
