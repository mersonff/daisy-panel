FactoryBot.define do
  factory :import_report do
    user
    filename { "test_import.csv" }
    status { "pending" }
    success_count { 0 }
    error_count { 0 }
    total_lines { 0 }
    started_at { nil }
    completed_at { nil }
    error_details { [] }
  end
end
