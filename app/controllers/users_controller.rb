require 'securerandom'
class UsersController < ApplicationController
  before_action :set_user, only: %i[ show edit update destroy ]
  before_action :check_login_user_cookie, except: %i[show_login login ]

  def index
    @users = User.all
  end

  def show
  end

  def new
    @user = User.new
  end

  def edit
  end

  def create
    @user = User.new(user_params)
    @user.save
    redirect_to user_url(@user), notice: "User was successfully created."
  end

  def update
    @user.update(user_params)
    redirect_to user_url(@user), notice: "User was successfully updated."
  end

  def destroy
    @user.destroy
  end

  def show_login
  end

  def login
    user = User.find_by_user_name(params[:username])
    if user.blank?
      redirect_to '/users/show_login', notice: "username and password not match" and return
    end
    Rails.logger.info "== user: #{user.inspect}"

    if Session.where("user_id = ?", user.id).last.present?
      redirect_to "/sessions", notice: 'already logged in' and return
    end

    # login, only create the session, not checK ip
    if user.password == params[:password]
      session_string = SecureRandom.hex(128)

      # create session for backend
      Session.create user_id: user.id, session_string: session_string ,
        ip: request.remote_ip,
        user_agent: request.user_agent

      # store session string in client
      cookies[:session_string] = {
        value: session_string
      }
      redirect_to '/sessions', notice: 'successfully logged in'
    else
      redirect_to '/users/show_login', notice: "username and password not match"
    end

  end

  private
    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:user_name, :password)
    end

    def check_login_user_cookie
      session_string = cookies[:session_string]
      if session_string.blank?
        redirect_to '/users/show_login', notice: "please login" and return
      end

      his_session = Session.where('session_string = ?', session_string).last
      if his_session.blank?
        redirect_to '/users/show_login', notice: "please login" and return
      end

      if his_session.ip != request.remote_ip
        Session.create user_id: his_session.user_id,
          session_string: session_string,
          ip: request.remote_ip,
          user_agent: request.user_agent
      end

    end
end
