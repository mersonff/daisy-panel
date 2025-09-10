FactoryBot.define do
  factory :import_report do
    user { nil }
    filename { "MyString" }
    status { "MyString" }
    success_count { 1 }
    error_count { 1 }
    total_lines { 1 }
    started_at { "2025-09-09 22:29:26" }
    completed_at { "2025-09-09 22:29:26" }
    error_details { "MyText" }
  end
end
