FactoryBot.define do
  factory :appointment do
    sequence(:name) { |n| "Compromisso #{n}" }
    sequence(:start_time) { |n| n.days.from_now.change(hour: 9, min: 0) }
    end_time { start_time + 1.hour }
    user

    trait :past do
      start_time { 1.day.ago.change(hour: 9, min: 0) }
      end_time { 1.day.ago.change(hour: 10, min: 0) }
    end

    trait :ongoing do
      start_time { 1.hour.ago }
      end_time { 1.hour.from_now }
    end

    trait :upcoming do
      start_time { 1.day.from_now.change(hour: 9, min: 0) }
      end_time { 1.day.from_now.change(hour: 10, min: 0) }
    end

    trait :long_duration do
      start_time { 2.days.from_now.change(hour: 9, min: 0) }
      end_time { 2.days.from_now.change(hour: 18, min: 0) }
    end

    trait :same_day_conflict do
      start_time { 1.day.from_now.change(hour: 9, min: 30) }
      end_time { 1.day.from_now.change(hour: 10, min: 30) }
    end
  end
end
