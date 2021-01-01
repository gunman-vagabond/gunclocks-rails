class UsersController < ApplicationController
  def index
  end

  def show
    @user = Hash.new
    if params[:username] == 'ryuba'
      @user[:name]     = 'Hikaru Ryuba'
      @user[:username] = 'ryuba'
      @user[:location] = 'Tokyo'
      @user[:about]    = 'Hello, I am Ryuba'
    elsif params[:username] == 'gunman'
      @user[:name]     = 'Gunman Vagabond'
      @user[:username] = 'gunman'
      @user[:location] = 'Tokyo'
      @user[:about]    = 'Hello, I am Gunman'
    end
  end
end
