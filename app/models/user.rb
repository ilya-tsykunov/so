class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, omniauth_providers: [:facebook]

  has_many :questions
  has_many :answers
  has_many :comments
  has_many :authorizations
  has_many :votings

  def self.find_for_oauth auth
    authorization = Authorization.where(provider: auth.provider, uid: auth.uid.to_s).first
    return authorization.user if authorization.present?

    email = auth.info[:email]
    user = User.where(email: email).first
    if user.blank?
      password = Devise.friendly_token[0, 20]
      user = User.create!(email: email, password: password, password_confirmation: password)
    end
    user.authorizations.create(provider: auth.provider, uid: auth.uid)
    user
  end

  def reputation
    Voting.where(votable_type: [Question.name, Answer.name]).where("#{Voting.quoted_table_name}.\"votable_id\" IN (#{Answer.where(user: self).select(:id).to_sql}) OR #{Voting.quoted_table_name}.\"votable_id\" IN (#{Question.where(user: self).select(:id).to_sql})").sum(:opinion)
  end
end
