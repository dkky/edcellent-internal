class UsersController < Clearance::UsersController

  def create
    if params[:user][:access] == 'student'
      @user = User.new(student_params)
      @user.password = 'bangbangda123'
      @user.save
      flash[:notice] = "Thank you #{@user.english_name}!"
      redirect_to student_profile_path
    else
      @user = user_from_params

      respond_to do |format|
        if @user.save
          format.html {redirect_back_or url_after_create }
          format.html { sign_in @user }
        else
          format.html { render template: "users/new"}
        end
      end
    end
  end

  # def edit
  #     @user = User.find(params[:id])
  # end

  # def update
  #     @user = User.find(params[:id])
  #     if @user.update(user_params)
  #       redirect_to '/home/index'
  #     else
  #       render 'edit'
  #     end
  # end
  def student
    @user = User.new
  end

  private

  # method from the gem 'clearance'
  def student_params
    params.require(:user).permit(:english_name, :first_name, :last_name, :email, :school, :year_level, :phone_number)
  end

  def user_params
    params.require(:user).permit(:english_name, :first_name, :last_name, :email, :password, :password_confirmation)
  end
  
  def user_from_params
    User.new(user_params)
  end
end