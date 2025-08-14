require 'rails_helper'

RSpec.describe "RewardWallets", type: :request do
  describe "GET /show" do
    it "returns http success" do
      get "/reward_wallets/show"
      expect(response).to have_http_status(:success)
    end
  end

end
