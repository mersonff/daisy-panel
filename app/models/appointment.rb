class Appointment < ApplicationRecord
  belongs_to :user

  validates :name, presence: true, length: { minimum: 3, maximum: 100 }
  validates :start_time, presence: true
  validates :end_time, presence: true
  validate :end_time_after_start_time
  validate :no_time_conflicts

  scope :for_user, ->(user_id) { where(user_id: user_id) }
  scope :upcoming, -> { where("start_time > ?", Time.current) }
  scope :past, -> { where("end_time < ?", Time.current) }
  scope :ongoing, -> { where("start_time <= ? AND end_time >= ?", Time.current, Time.current) }
  scope :ordered_by_start_time, -> { order(:start_time) }

  def duration
    return nil unless start_time && end_time
    ((end_time - start_time) / 1.hour).round(2)
  end

  def status
    now = Time.current
    if end_time < now
      "past"
    elsif start_time <= now && end_time >= now
      "ongoing"
    else
      "upcoming"
    end
  end

  def overlaps_with?(other_appointment)
    return false if other_appointment == self
    return false unless other_appointment.is_a?(Appointment)

    start_time < other_appointment.end_time && end_time > other_appointment.start_time
  end

  private

  def end_time_after_start_time
    return unless start_time && end_time

    if end_time <= start_time
      errors.add(:end_time, "deve ser posterior ao horário de início")
    end
  end

  def no_time_conflicts
    return unless start_time && end_time && user_id

    conflicting_appointments = user.appointments
                                  .where.not(id: id)
                                  .where(
                                    "(start_time < ? AND end_time > ?) OR (start_time < ? AND end_time > ?) OR (start_time >= ? AND end_time <= ?)",
                                    end_time, start_time,
                                    start_time, start_time,
                                    start_time, end_time
                                  )

    if conflicting_appointments.exists?
      conflicting = conflicting_appointments.first
      errors.add(:base, "Conflito de horário com o compromisso '#{conflicting.name}' (#{conflicting.start_time.strftime('%d/%m/%Y %H:%M')} - #{conflicting.end_time.strftime('%d/%m/%Y %H:%M')})")
    end
  end
end
