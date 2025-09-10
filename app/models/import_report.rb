class ImportReport < ApplicationRecord
  belongs_to :user

  serialize :error_details, coder: JSON

  enum :status, {
    pending: "pending",
    processing: "processing",
    completed: "completed",
    failed: "failed"
  }

  scope :recent, -> { order(created_at: :desc) }
  scope :for_user, ->(user) { where(user: user) }

  def success_rate
    return 0 if total_lines.to_i.zero?
    ((success_count.to_f / total_lines.to_f) * 100).round(2)
  end

  def error_rate
    return 0 if total_lines.to_i.zero?
    ((error_count.to_f / total_lines.to_f) * 100).round(2)
  end

  def duration
    return nil unless started_at && completed_at
    completed_at - started_at
  end

  def errors_list
    error_details || []
  end
end
