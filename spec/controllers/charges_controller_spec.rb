require 'rails_helper'

RSpec.describe ChargesController, type: :controller do

  let(:my_user) { create(:user) }

  describe "GET #create" do
    before do
        @user = User.create!(email: "user@bloccit.com", password: "helloworld", role: :standard)
        @user.confirmed_at = Time.zone.now
        @user.save
        @request.env["devise.mapping"] = Devise.mappings[:user]
        sign_in @user
    end
    it "returns http success" do
      get :create, user: @user
      expect(response).to have_http_status(:success)
    end
  end

end
