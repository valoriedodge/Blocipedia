require 'rails_helper'

RSpec.describe Wiki, type: :model do
  let(:wiki) { Wiki.create!(title: "New Wiki Title", body: "New Wiki Body", private: false) }

  it { is_expected.to belong_to(:user)}

  it { is_expected.to validate_presence_of(:title)}
  it { is_expected.to validate_presence_of(:body)}

  it {is_expected.to validate_length_of(:title).is_at_least(5)}
  it {is_expected.to validate_length_of(:body).is_at_least(10)}

   describe "attributes" do
     it "has title, body and boolean attributes" do
       expect(wiki).to have_attributes(title: "New Wiki Title", body: "New Wiki Body", private: false)
     end
   end
end
