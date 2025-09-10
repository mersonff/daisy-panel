require 'rails_helper'

RSpec.describe ImportReport, type: :model do
  it { should belong_to(:user) }

  describe 'scopes' do
    describe '.recent' do
      it 'returns reports ordered by created_at descending' do
        user = create(:user)
        older_report = create(:import_report, user: user, created_at: 2.days.ago)
        newer_report = create(:import_report, user: user, created_at: 1.day.ago)

        recent_reports = ImportReport.where(user: user).recent.to_a
        expect(recent_reports).to eq([ newer_report, older_report ])
      end
    end

    describe '.for_user' do
      it 'returns reports for the specified user' do
        user1 = create(:user)
        user2 = create(:user)
        report1 = create(:import_report, user: user1)
        report2 = create(:import_report, user: user2)

        expect(ImportReport.for_user(user1.id)).to include(report1)
        expect(ImportReport.for_user(user1.id)).not_to include(report2)
      end
    end
  end

  describe '#methods' do
    let(:user) { create(:user) }
    let(:report) { create(:import_report, user: user, total_lines: 10) }

    describe '#success_rate' do
      it 'calculates the success rate correctly' do
        report.update(success_count: 7, error_count: 3)
        expect(report.success_rate).to eq(70.0)
      end

      it 'returns 0.0 if total_lines is zero' do
        report.update(total_lines: 0, success_count: 0, error_count: 0)
        expect(report.success_rate).to eq(0.0)
      end
    end

    describe '#error_rate' do
      it 'calculates the error rate correctly' do
        report.update(success_count: 7, error_count: 3)
        expect(report.error_rate).to eq(30.0)
      end

      it 'returns 0.0 if total_lines is zero' do
        report.update(total_lines: 0, success_count: 0, error_count: 0)
        expect(report.error_rate).to eq(0.0)
      end
    end

    describe '#duration' do
      it 'calculates the duration between started_at and completed_at' do
        start_time = 2.hours.ago
        end_time = 1.hour.ago
        report.update(started_at: start_time, completed_at: end_time)
        expect(report.duration).to be_within(1.second).of(1.hour)
      end

      it 'returns nil if started_at or completed_at is nil' do
        report.update(started_at: nil, completed_at: Time.current)
        expect(report.duration).to be_nil

        report.update(started_at: Time.current, completed_at: nil)
        expect(report.duration).to be_nil
      end
    end

    describe '#errors_list' do
      it 'returns the error details as stored' do
        error_details = [
          { "line" => 2, "name" => "John Doe", "cpf" => "12345678900", "errors" => [ "Nome não pode ficar em branco" ] },
          { "line" => 3, "name" => "Jane Smith", "cpf" => "09876543211", "errors" => [ "CPF inválido" ] }
        ]
        report.update(error_details: error_details)

        expect(report.errors_list).to eq(error_details)
      end
    end
  end
end
