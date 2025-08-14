require 'rails_helper'

RSpec.describe "Carts", type: :request do
  describe "GET /cart" do
    it "returns http success when authenticated" do
      user = create(:user)
      sign_in user
      get cart_path
      expect(response).to have_http_status(:success)
    end

    it "redirects to login when not authenticated" do
      get cart_path
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "PATCH /cart" do
    it "updates cart successfully" do
      user = create(:user)
      sign_in user
      patch cart_path
      expect(response).to redirect_to(cart_path)
    end
  end

  describe "DELETE /cart" do
    it "clears cart successfully" do
      user = create(:user)
      sign_in user
      delete cart_path
      expect(response).to redirect_to(cart_path)
    end
  end

  describe "DELETE /remove_item" do
    let(:user) { create(:user) }
    let(:product) { create(:product) }
    let(:cart_item) { create(:cart, user: user, product: product, quantity: 1) }

    before do
      sign_in user
      cart_item
    end

    it "removes the item from cart" do
      expect {
        delete remove_item_cart_path, params: { 
          product_id: product.id, 
          product_variant_id: nil 
        }
      }.to change { user.cart_items.count }.by(-1)

      expect(response).to redirect_to(cart_path)
      expect(flash[:notice]).to eq('Item removed from cart successfully.')
    end

    it "handles non-existent item gracefully" do
      delete remove_item_cart_path, params: { 
        product_id: 99999, 
        product_variant_id: nil 
      }

      expect(response).to redirect_to(cart_path)
      expect(flash[:alert]).to eq('Item not found in cart.')
    end
  end

end
