class Client < ApplicationRecord
  belongs_to :user

  VALID_STATES = %w[
    AC AL AP AM BA CE DF ES GO MA MT MS MG PA PB PR PE PI RJ RN RS RO RR SC SP SE TO
  ].freeze

  validates :name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :address, presence: true, length: { minimum: 5, maximum: 200 }
  validates :city, presence: true, length: { minimum: 2, maximum: 100 }
  validates :state, presence: true, length: { is: 2 }, inclusion: { in: VALID_STATES, message: "não é um estado válido" }
  validates :cep, presence: true, format: { with: /\A\d{5}-?\d{3}\z/, message: "deve ter formato 12345-678" }
  validates :phone, presence: true
  validates :cpf, presence: true, uniqueness: { scope: :user_id, message: "já está cadastrado" }, cpf: true

  validate :phone_format_validation

  scope :search_by_name, ->(name) { where("name ILIKE ?", "%#{name}%") }
  scope :search_by_cpf, ->(cpf) { where("cpf ILIKE ?", "%#{cpf.gsub(/\D/, '')}%") }
  scope :search_by_phone, ->(phone) { where("phone ILIKE ?", "%#{phone}%") }
  scope :search_general, ->(term) {
    sanitized_cpf = term.gsub(/\D/, "")

    if sanitized_cpf.present?
      where("name ILIKE ? OR cpf ILIKE ? OR phone ILIKE ?",
            "%#{term}%", "%#{sanitized_cpf}%", "%#{term}%")
    else
      where("name ILIKE ? OR phone ILIKE ?", "%#{term}%", "%#{term}%")
    end
  }
  scope :order_by_name, -> { order(:name) }
  scope :order_by_state, -> { order(:state, :city, :name) }
  scope :order_by_created_at, -> { order(created_at: :desc) }

  before_validation :format_cpf
  before_validation :format_cep
  before_validation :format_phone
  before_validation :upcase_state
  before_validation :upcase_name

  after_create :broadcast_stats_update
  after_destroy :broadcast_stats_update

  # Método to_s para representação em string
  def to_s
    name
  end

  private

  def format_cpf
    return unless cpf.present?
    self.cpf = cpf.gsub(/\D/, "")
  end

  def format_cep
    return unless cep.present?
    self.cep = cep.gsub(/\D/, "").insert(5, "-") if cep.gsub(/\D/, "").length == 8
  end

  def format_phone
    return unless phone.present?
    clean_phone = phone.gsub(/\D/, "")
    if clean_phone.length == 11
      self.phone = "(#{clean_phone[0, 2]}) #{clean_phone[2, 5]}-#{clean_phone[7, 4]}"
    elsif clean_phone.length == 10
      self.phone = "(#{clean_phone[0, 2]}) #{clean_phone[2, 4]}-#{clean_phone[6, 4]}"
    end
  end

  def upcase_state
    self.state = state.upcase if state.present?
  end

  def upcase_name
    self.name = name.upcase if name.present?
  end

  def phone_format_validation
    return unless phone.present?

    # Verifica se está no formato correto após formatação
    unless phone.match?(/\A\(\d{2}\)\s\d{4,5}-\d{4}\z/)
      errors.add(:phone, "deve ter formato (11) 99999-9999")
    end
  end

  def broadcast_stats_update
    PublicDashboardBroadcaster.broadcast_stats
  end
end
