require 'rails_helper'

RSpec.describe "Checkout", type: :request do
  describe "GET /checkout" do
    it "redirects to login when not authenticated" do
      get checkout_path
      expect(response).to redirect_to(new_user_session_path)
    end

    it "returns http success when authenticated with cart items" do
      user = create(:user)
      cart_item = create(:cart, user: user)
      address = create(:address, user: user)
      sign_in user
      get checkout_path
      expect(response).to have_http_status(:success)
    end

    it "redirects to cart when cart is empty" do
      user = create(:user)
      sign_in user
      get checkout_path
      expect(response).to redirect_to(cart_path)
    end
  end

  describe "GET /checkout/shipping" do
    it "redirects to login when not authenticated" do
      get shipping_checkout_path
      expect(response).to redirect_to(new_user_session_path)
    end

    it "returns http success when authenticated with cart items" do
      user = create(:user)
      cart_item = create(:cart, user: user)
      address = create(:address, user: user)
      sign_in user
      get shipping_checkout_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /checkout/payment" do
    it "redirects to login when not authenticated" do
      get payment_checkout_path
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "GET /checkout/confirmation" do
    it "redirects to login when not authenticated" do
      get confirmation_checkout_path
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "PATCH /checkout" do
    it "redirects to login when not authenticated" do
      patch checkout_path
      expect(response).to redirect_to(new_user_session_path)
    end
  end
end
