require 'rails_helper'

RSpec.describe "Referrals", type: :request do
  describe "GET /show" do
    it "returns http success" do
      get "/referrals/show"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /apply" do
    it "returns http success" do
      get "/referrals/apply"
      expect(response).to have_http_status(:success)
    end
  end

end
