require 'rails_helper'

RSpec.describe "Admin::Rewards", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/admin/rewards/index"
      expect(response).to have_http_status(:success)
    end
  end

end
