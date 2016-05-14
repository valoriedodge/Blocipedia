require 'rails_helper'

RSpec.describe Wiki, type: :model do
  let(:wiki) { Wiki.create!(title: "New Wiki Title", body: "New Wiki Body", private: false) }

  it { is_expected.to belong_to(:user)}
  it { is_expected.to belong_to(:wiki)}

end
