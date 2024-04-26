class SessionsController  < ApplicationController
  def index
  end

  def destroy
    Session.find(params[:id]).delete
    redirect_to '/sessions', notice: 'successfully deleted'
  end
end
