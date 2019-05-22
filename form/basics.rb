class RegistrationForm
  include ActiveModel::Model

  attr_accessor :company_name, :email, :first_name,
                :last_name, :terms_of_service

  validates :company_name, presence: true
  validates :email, presence: true, email: true
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :terms_of_service, acceptance: true

  def save
    return false if invalid?

    # Do something interesting here
    # - create user
    # - send notifications
    # - log events, etc.
  end

  private

  def create_user
    # method implementation ...
  end
end

form = RegistrationForm.new(params)
render_error unless form.save
