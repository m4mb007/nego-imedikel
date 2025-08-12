require 'rails_helper'

RSpec.describe "Stores", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/stores/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get "/stores/show"
      expect(response).to have_http_status(:success)
    end
  end

end
