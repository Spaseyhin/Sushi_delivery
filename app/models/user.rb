class User < ApplicationRecord
  validates :phone_number, presence: true, uniqueness: true
  validates :confirmation_code, length: { is: 6 }, allow_nil: true

  # Генерация кода подтверждения
  def generate_confirmation_code!
    self.confirmation_code = rand(100_000..999_999).to_s
    self.confirmation_code_sent_at = Time.current
    save!
  end

  def verify
    if params[:confirmation_code] == session[:otp_code]
      flash[:notice] = 'Successfully verified!'
      session.delete(:otp_code) # Очистка кода после успешного подтверждения
      redirect_to root_path
    else
      flash[:alert] = 'Invalid code! Try again.'

      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace('auth_form', partial: 'users/enter_code')
        end
      end
    end
  end

  # Проверка валидности кода
  def valid_confirmation_code?(code)
    return false if confirmation_code.nil? || confirmation_code_sent_at < 10.minutes.ago

    confirmation_code == code
  end
end
