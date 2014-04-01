require 'test_helper'

class UserStoriesTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end

#  testing only the purchase of a product
  fixtures :products

#    test name
    test "buying a product" do

#      by the end of the test, we know we'll want to have added an order to
#      the orders table and a line item to the line_items table, so lets empty them out before we start.
      LineItem.delete_all
      Order.delete_all
      #      Because we will be using Ruby book fixture adata alot, load it into a local variable
      ruby_book = products(:ruby)

#      Look like a functional test
#      main difference: get method
#      functional test: an action when calling get
#      integration test: wander all app -> pass in a full(relative) URL for the controller and action to be invoked
      get "/"
      assert_response :success
      assert_template "index"

#      Use Ajax request to add things to cart -> xml_http_request() to invoke the action
      xml_http_request :post, '/line_items', product_id: ruby_book.id
      assert_response :success

#      When it returns, check that the cart now contains the requested product
      cart = Cart.find(session[:cart_id])
      assert_equal 1, cart.line_items.size
      assert_equal ruby_book, cart.line_items[0].product

#      Then they check out
      get "/orders/new"
      assert_response :success
      assert_template "new"

#      test helper method post_via_redirect() generates the post request and then follows any redirects returned until a nonredirect response is returned.
      post_via_redirect "/orders",
                        order: { name: "Dave Thomas",
                                 address: "123 The Street",
                                 email: "dave@example.com",
                                 pay_type: "Check" }
      assert_response :success
#      redirected to the index
      assert_template "index"
#      check that the cart is now empty
      cart = Cart.find(session[:cart_id])
      assert_equal 0, cart.line_items.size

#      Wander into the database
#      make sure we have created an order
      orders = Order.all
      assert_equal 1, orders.size
      order = orders[0]

#      corresponding line item and that the datails are correct
      assert_equal "Dave Thomas", order.name
      assert_equal "123 The Street", order.address
      assert_equal "dave@example.com", order.email
      assert_equal "Check", order.pay_type

      assert_equal 1, order.line_items.size
      line_item = order.line_items[0]
      assert_equal ruby_book, line_item.product

#      verify that the mail itself is correctly addressed and has the expected subject line.
      mail = ActionMailer::Base.deliveries.last
      assert_equal ["dave@example.com"], mail.to
      assert_equal 'Sam Ruby <depot@example.com>', mail[:from].value
      assert_equal "Pragmatic Store Order Confirmation", mail.subject
  end
end
