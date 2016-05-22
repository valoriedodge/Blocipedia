require 'rails_helper'
require 'random_data'

RSpec.describe CollaboratorsController, type: :controller do

  let(:my_user) { FactoryGirl.create(:user)}
  let(:collaborator) { FactoryGirl.create(:user)}
  let(:my_wiki) { Wiki.create!(title: "New Wiki Title", body: "New Wiki Body", private: false) }
  let(:my_private_wiki) { Wiki.create!(title: "New Wiki Title", body: "New Wiki Body", private: true) }

  describe "remove collaborator" do
      before do
        my_private_wiki.collaborators << collaborator
      end

      it "should remove collaborator from wiki" do
        expect(my_private_wiki.collaborators).to include(collaborator)
        put :remove, wiki_id: my_private_wiki.id, id: collaborator.id
        my_private_wiki.collaborators.reload
        expect(my_private_wiki.collaborators).to_not include(collaborator)
      end

      it "should change the size" do
        expect(my_private_wiki.collaborators.size).to eq(1)
        put :remove, wiki_id: my_private_wiki.id, id: collaborator.id
        expect(my_private_wiki.collaborators.size).to eq(0)
      end

      it "should redirect to all wikis" do
        put :remove, wiki_id: my_private_wiki.id, id: collaborator.id
        expect(response).to redirect_to(wikis_path)
      end
  end
end
