# == Schema Information
#
# Table name: authors
#
#  id                     :bigint           not null, primary key
#  first_name             :string
#  last_name              :string
#  gender                 :string
#  birthday               :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  email                  :string
#  password_digest        :string
#  admin                  :boolean          default(FALSE)
#  banned                 :boolean          default(FALSE)
#  email_confirmed        :boolean          default(FALSE)
#  confirm_token          :string
#  password_reset_sent_at :datetime
#

class Author < ApplicationRecord
  has_secure_password
  # confirm
  before_create :confirmation_token
  after_create :send_confirmation

  has_many :posts, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :likes, dependent: :destroy

  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, :first_name, :last_name, presence: true, allow_nil: true
  validate :pass_val

  def pass_val
    # next line avoid error with ActiveAdmin
    if password.present?
      if password.count('a-z') <= 0 || password.count('A-Z') <= 0 || password.count('0-9') <= 0
        errors.add(:password, 'must contain 1 small letter, 1 capital letter, 1 number and minimum 8 symbols')
      end
    end
  end

  def full_name
    "#{first_name.capitalize} #{last_name.capitalize}"
  end

  # confirm
  def email_activate
    self.email_confirmed = true
    self.confirm_token = nil
    save!(validate: false)
  end

  def send_confirmation
    AuthorMailer.registration_confirmation(self).deliver!
  end

  # password reset
  def send_password_reset
    confirmation_token
    self.password_reset_sent_at = Time.zone.now
    save!(validate: true)
    AuthorMailer.password_reset(self).deliver!
  end

  private

  # token
  def confirmation_token
    self.confirm_token = SecureRandom.urlsafe_base64.to_s if confirm_token.nil?
  end
end
