require 'rails_helper'
require 'stripe_mock'

RSpec.describe ChargesController, type: :controller do

  let(:stripe_helper) { StripeMock.create_test_helper }
  before { StripeMock.start }
  after { StripeMock.stop }

  it "creates a stripe customer" do

    # This doesn't touch stripe's servers nor the internet!
    # Specify :source in place of :card (with same value) to return customer with source data
    @customer = Stripe::Customer.create({
      email: 'johnny@appleseed.com',
      card: stripe_helper.generate_card_token
    })
    expect(@customer.email).to eq('johnny@appleseed.com')
  end

  describe "GET #create" do
    before do
        @user = User.create!(email: "user@bloccit.com", password: "helloworld", role: :standard)
        @user.confirmed_at = Time.zone.now
        @user.save
        @request.env["devise.mapping"] = Devise.mappings[:user]
        sign_in @user
    end

    it "upgrades the user to premium" do
      expect(@user.role).to eq("standard")
      post :create, user: @user
      @user.reload
      expect(@user.role).to eq("premium")
    end

    it "returns http success" do
      post :create, user: @user
      expect(response).to redirect_to wikis_path(@user)
    end
  end

end
