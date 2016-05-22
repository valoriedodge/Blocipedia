require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) { User.create!(email: "user@example.com", password: "password")}

  it { is_expected.to have_many(:created_wikis) }
  it { is_expected.to have_many(:collaborating_wikis).through(:collaborations) }

  describe "attributes" do
    it "has an email and password"do
      expect(user).to have_attributes(email: user.email, password: user.password)
    end

    it "responds to role" do
      expect(user).to respond_to(:role)
    end

    it "responds to standard?" do
      expect(user).to respond_to(:standard?)
    end

    it "responds to premium?" do
      expect(user).to respond_to(:premium?)
    end

    it "responds to admin?" do
      expect(user).to respond_to(:admin?)
    end
  end

  describe "roles" do
    it "is standard by default" do
      expect(user.role).to eq("standard")
    end
    context "standard user" do
      it "returns true for standard?" do
        expect(user.standard?).to be_truthy
      end

      it "returns false for premium?" do
        expect(user.premium?).to be_falsey
      end

      it "returns false for admin?" do
        expect(user.admin?).to be_falsey
      end
    end

    context "premium user" do
      before do
        user.premium!
      end
      it "returns true for standard?" do
        expect(user.standard?).to be_falsey
      end

      it "returns false for premium?" do
        expect(user.premium?).to be_truthy
      end

      it "returns false for admin?" do
        expect(user.admin?).to be_falsey
      end
    end

    context "admin user" do
      before do
        user.admin!
      end
      it "returns true for standard?" do
        expect(user.standard?).to be_falsey
      end

      it "returns false for premium?" do
        expect(user.premium?).to be_falsey
      end

      it "returns false for admin?" do
        expect(user.admin?).to be_truthy
      end
    end
  end

  describe "invalid user" do
      let(:user_with_invalid_email) { User.create(email: "", password: "password") }

      it "should be an invalid user due to blank email" do
          expect(user_with_invalid_email).to_not be_valid
      end

    end

  describe "downgrade user" do

      let(:my_user) { User.create!(email: "my_user@example.com", password: "password", role: "premium")}
      let(:my_wiki) { Wiki.create!(title: "New Wiki Title", body: "New Wiki Body", private: false, creator: my_user) }
      let(:my_private_wiki) { Wiki.create!(title: "New Wiki Title", body: "New Wiki Body", private: true, creator: my_user) }

      it "should change role from premium to standard" do
          expect(my_user.role).to eq("premium")
          my_user.downgrade
          expect(my_user.role).to eq("standard")
      end

      #it "returns only public wikis if user is standard" do
        #@user.standard!
        #expect(Wiki.visible_to(@user)).to eq([@public_wiki])
      #end

      it "changes private wikis to public" do
        expect(my_private_wiki.private).to be(true)
        my_user.downgrade
        my_private_wiki.reload
        expect(my_private_wiki.private).to be(false)
      end

      it "keeps public wikis public" do
        expect(my_wiki.private).to be(false)
        user.downgrade
        expect(my_wiki.private).to be(false)
      end

      it "keeps all wikis assigned to user" do
        expect(user.created_wikis).to eq(Wiki.all)
      end

  end
end
