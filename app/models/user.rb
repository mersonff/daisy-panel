class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :clients, dependent: :destroy
  has_many :import_reports, dependent: :destroy
  has_many :appointments, dependent: :destroy

  def self.create_admin(email, password)
    create!(email: email, password: password, password_confirmation: password, admin: true)
  end
end
