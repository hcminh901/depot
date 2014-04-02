class StoreController < ApplicationController
  skip_before_action :authorize
  include CurrentCart
  before_action :set_cart

  def increment_counter
  if session[:counter].nil?
    session[:counter] = 0
  end
  session[:counter] += 1
  end

  def index
    @count = increment_counter
    if params[:set_locale]
      redirect_to store_url(locale: params[:set_locale])
    else
    @products = Product.order(:title)
    end
  end
end
