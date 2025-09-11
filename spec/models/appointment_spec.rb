require 'rails_helper'

RSpec.describe Appointment, type: :model do
  let(:user) { create(:user) }
  let(:appointment) { build(:appointment, user: user) }

  describe 'associations' do
    it { should belong_to(:user) }
  end

  describe 'validations' do
    context 'presence validations' do
      it { should validate_presence_of(:name) }
      it { should validate_presence_of(:start_time) }
      it { should validate_presence_of(:end_time) }
    end

    context 'name validation' do
      it { should validate_length_of(:name).is_at_least(3).is_at_most(100) }

      it 'is valid with a valid name' do
        appointment.name = 'Reunião importante'
        expect(appointment).to be_valid
      end

      it 'is invalid with a name too short' do
        appointment.name = 'AB'
        expect(appointment).to_not be_valid
        expect(appointment.errors[:name]).to include('é muito curto (mínimo: 3 caracteres)')
      end

      it 'is invalid with a name too long' do
        appointment.name = 'A' * 101
        expect(appointment).to_not be_valid
        expect(appointment.errors[:name]).to include('é muito longo (máximo: 100 caracteres)')
      end
    end

    context 'time validation' do
      it 'is valid when end_time is after start_time' do
        appointment.start_time = 1.day.from_now
        appointment.end_time = 1.day.from_now + 1.hour
        expect(appointment).to be_valid
      end

      it 'is invalid when end_time is before start_time' do
        appointment.start_time = 1.day.from_now + 1.hour
        appointment.end_time = 1.day.from_now
        expect(appointment).to_not be_valid
        expect(appointment.errors[:end_time]).to include('deve ser posterior ao horário de início')
      end

      it 'is invalid when end_time equals start_time' do
        time = 1.day.from_now
        appointment.start_time = time
        appointment.end_time = time
        expect(appointment).to_not be_valid
        expect(appointment.errors[:end_time]).to include('deve ser posterior ao horário de início')
      end
    end

    context 'conflict validation' do
      let!(:existing_appointment) do
        create(:appointment,
               user: user,
               start_time: 1.day.from_now.change(hour: 9, min: 0),
               end_time: 1.day.from_now.change(hour: 10, min: 0))
      end

      it 'is invalid when appointment conflicts with existing appointment' do
        conflicting_appointment = build(:appointment,
                                       user: user,
                                       start_time: 1.day.from_now.change(hour: 9, min: 30),
                                       end_time: 1.day.from_now.change(hour: 10, min: 30))

        expect(conflicting_appointment).to_not be_valid
        expect(conflicting_appointment.errors[:base]).to include(/Conflito de horário/)
      end

      it 'is valid when appointment does not conflict' do
        non_conflicting_appointment = build(:appointment,
                                           user: user,
                                           start_time: 1.day.from_now.change(hour: 11, min: 0),
                                           end_time: 1.day.from_now.change(hour: 12, min: 0))

        expect(non_conflicting_appointment).to be_valid
      end

      it 'allows same time for different users' do
        other_user = create(:user)
        same_time_appointment = build(:appointment,
                                     user: other_user,
                                     start_time: existing_appointment.start_time,
                                     end_time: existing_appointment.end_time)

        expect(same_time_appointment).to be_valid
      end

      it 'allows updating the same appointment' do
        existing_appointment.name = 'Updated name'
        expect(existing_appointment).to be_valid
      end

      context 'edge cases' do
        it 'is valid when new appointment starts exactly when existing ends' do
          non_conflicting = build(:appointment,
                                 user: user,
                                 start_time: existing_appointment.end_time,
                                 end_time: existing_appointment.end_time + 1.hour)

          expect(non_conflicting).to be_valid
        end

        it 'is valid when new appointment ends exactly when existing starts' do
          non_conflicting = build(:appointment,
                                 user: user,
                                 start_time: existing_appointment.start_time - 1.hour,
                                 end_time: existing_appointment.start_time)

          expect(non_conflicting).to be_valid
        end
      end
    end
  end

  describe 'scopes' do
    let!(:past_appointment) { create(:appointment, :past, user: user) }
    let!(:ongoing_appointment) { create(:appointment, :ongoing, user: user) }
    let!(:upcoming_appointment) { create(:appointment, :upcoming, user: user) }

    describe '.for_user' do
      let(:other_user) { create(:user) }
      let!(:other_user_appointment) { create(:appointment, user: other_user) }

      it 'returns appointments for specific user' do
        results = Appointment.for_user(user.id)
        expect(results).to include(past_appointment, ongoing_appointment, upcoming_appointment)
        expect(results).to_not include(other_user_appointment)
      end
    end

    describe '.upcoming' do
      it 'returns only upcoming appointments' do
        results = Appointment.upcoming
        expect(results).to include(upcoming_appointment)
        expect(results).to_not include(past_appointment, ongoing_appointment)
      end
    end

    describe '.past' do
      it 'returns only past appointments' do
        results = Appointment.past
        expect(results).to include(past_appointment)
        expect(results).to_not include(ongoing_appointment, upcoming_appointment)
      end
    end

    describe '.ongoing' do
      it 'returns only ongoing appointments' do
        results = Appointment.ongoing
        expect(results).to include(ongoing_appointment)
        expect(results).to_not include(past_appointment, upcoming_appointment)
      end
    end

    describe '.ordered_by_start_time' do
      it 'returns appointments ordered by start time' do
        results = user.appointments.ordered_by_start_time
        expect(results.first).to eq(past_appointment)
        expect(results.last).to eq(upcoming_appointment)
      end
    end
  end

  describe 'instance methods' do
    context '#duration' do
      it 'calculates duration in hours' do
        appointment.start_time = Time.current
        appointment.end_time = Time.current + 2.hours
        appointment.save
        expect(appointment.duration).to eq(2.0)
      end

      it 'returns nil if start_time or end_time is missing' do
        appointment.start_time = nil
        expect(appointment.duration).to be_nil
      end

      it 'handles fractional hours' do
        appointment.start_time = Time.current
        appointment.end_time = Time.current + 90.minutes
        appointment.save
        expect(appointment.duration).to eq(1.5)
      end
    end

    context '#status' do
      it 'returns "past" for past appointments' do
        appointment.start_time = 2.hours.ago
        appointment.end_time = 1.hour.ago
        expect(appointment.status).to eq('past')
      end

      it 'returns "ongoing" for ongoing appointments' do
        appointment.start_time = 1.hour.ago
        appointment.end_time = 1.hour.from_now
        expect(appointment.status).to eq('ongoing')
      end

      it 'returns "upcoming" for upcoming appointments' do
        appointment.start_time = 1.hour.from_now
        appointment.end_time = 2.hours.from_now
        expect(appointment.status).to eq('upcoming')
      end
    end

    context '#overlaps_with?' do
      let(:base_appointment) do
        build(:appointment,
              start_time: Time.current + 1.hour,
              end_time: Time.current + 2.hours)
      end

      it 'returns true for overlapping appointments' do
        overlapping = build(:appointment,
                           start_time: Time.current + 1.5.hours,
                           end_time: Time.current + 2.5.hours)

        expect(base_appointment.overlaps_with?(overlapping)).to be true
      end

      it 'returns false for non-overlapping appointments' do
        non_overlapping = build(:appointment,
                               start_time: Time.current + 3.hours,
                               end_time: Time.current + 4.hours)

        expect(base_appointment.overlaps_with?(non_overlapping)).to be false
      end

      it 'returns false when comparing with itself' do
        expect(base_appointment.overlaps_with?(base_appointment)).to be false
      end

      it 'returns false when comparing with non-appointment object' do
        expect(base_appointment.overlaps_with?("not an appointment")).to be false
      end

      it 'returns false for adjacent appointments' do
        adjacent = build(:appointment,
                        start_time: base_appointment.end_time,
                        end_time: base_appointment.end_time + 1.hour)

        expect(base_appointment.overlaps_with?(adjacent)).to be false
      end
    end
  end

  describe 'factory' do
    it 'has a valid factory' do
      expect(appointment).to be_valid
    end

    it 'has valid factory traits' do
      expect(build(:appointment, :past)).to be_valid
      expect(build(:appointment, :ongoing)).to be_valid
      expect(build(:appointment, :upcoming)).to be_valid
      expect(build(:appointment, :long_duration)).to be_valid
    end
  end
end
