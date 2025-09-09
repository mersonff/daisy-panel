class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Only allow registration through console/seeds for admin users
  def self.create_admin(email, password)
    create!(email: email, password: password, password_confirmation: password)
  end
end
