class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
#  Turn on request forgery protection. Bear in mind that only non-GET, HTML/Javascript requests are checked
  protect_from_forgery with: :exception
end
