class UsersController < ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = User.find_or_create_by(phone_number: params[:phone_number]) # Теперь пользователь создаётся

    session[:otp_codes] ||= {} # Создаём хэш, если его нет
    session[:otp_codes][params[:phone_number]] = rand(1000..9999).to_s
    session[:otp_expires] ||= {} # Добавляем срок жизни кода
    session[:otp_expires][params[:phone_number]] = 5.minutes.from_now

    Rails.logger.info "Generated OTP for #{@user.phone_number}: #{session[:otp_codes][params[:phone_number]]}" # Логируем код

    respond_to do |format|
      format.turbo_stream
    end
  end

  def verify
    @user = User.find_or_create_by(phone_number: params[:phone_number]) # Теперь новый пользователь создаётся здесь тоже
    stored_code = session[:otp_codes]&.dig(params[:phone_number]) # Получаем код

    Rails.logger.info "User entered code: #{params[:confirmation_code]}, Stored code: #{stored_code}" # Логируем код

    if stored_code.present? && params[:confirmation_code] == stored_code
      session[:user_id] = @user.id # Логиним пользователя
      session[:otp_codes].delete(params[:phone_number]) # Очищаем код

      flash[:notice] = 'Successfully verified!'
      redirect_to root_path
    else
      flash[:alert] = 'Invalid code! Try again.'
      redirect_to new_user_path
    end
  end

  def logout
    session.delete(:user_id) # Удаляем сессию пользователя
    flash[:notice] = 'Logged out successfully.'
    redirect_to root_path
  end

  private

  def user_params
    params.require(:user).permit(:phone_number)
  end
end
