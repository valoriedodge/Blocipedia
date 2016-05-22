require 'rails_helper'
require 'random_data'

RSpec.describe WikisController, type: :controller do

  let(:my_user) { FactoryGirl.create(:user)}
  let(:other_user) { FactoryGirl.create(:user)}
  let(:collaborator) { FactoryGirl.create(:user)}
  let(:premium_user) { User.create!(email: "premium@me.com", password: "password", role: "premium")}
  let(:admin_user) { User.create!(email: "admin@me.com", password: "password", role: "admin")}
  let(:my_wiki) { Wiki.create!(title: "New Wiki Title", body: "New Wiki Body", private: false, creator: my_user) }
  let(:my_private_wiki) { Wiki.create!(title: "Private Wiki Title", body: "Private Wiki Body", private: true, creator: premium_user) }
  let(:other_wiki) { Wiki.create!(title: "Other Wiki Title", body: "Other Wiki Body", private: false, creator: other_user) }
  let(:other_private_wiki) { Wiki.create!(title: "Other Private Wiki Title", body: "Other Private Wiki Body", private: true, creator: other_user) }

  context "wiki specs" do
    describe "Wiki privacy" do
      it "should be private if private" do
        expect(my_private_wiki.private).to eq(true)
        expect(other_private_wiki.private).to eq(true)
      end

      it "should be public if public" do
        expect(my_wiki.private).to eq(false)
        expect(other_wiki.private).to eq(false)
      end
    end

    describe "Wiki creator" do
      it "should be my user" do
        expect(my_wiki.creator).to eq(my_user)
        expect(my_private_wiki.creator).to eq(premium_user)
      end

      it "should be other user" do
        expect(other_wiki.creator).to eq(other_user)
        expect(other_private_wiki.creator).to eq(other_user)
      end
    end
  end

  context "guest user" do
   describe "GET #index" do
     it "returns http success" do
       get :index
       expect(response).to have_http_status(:success)
     end

     it "renders the #index view" do
       get :index
       expect(response).to render_template :index
     end

     it "does not include private wikis in @wikis" do
         get :index
         expect(assigns(:wikis)).not_to include(my_private_wiki)
     end

     #it "assigns wiki to @wikis" do
      # get :index
       #expect(assigns(:wikis)).to eq([my_wiki])
     #end
   end

   describe "GET #show for public wiki" do
     it "returns http success" do
       get :show, id: my_wiki.id
       expect(response).to have_http_status(:success)
     end

     it "renders the #show view" do
       get :show, id: my_wiki.id
       expect(response).to render_template :show
     end

     it "assigns wiki to @wikis" do
       get :show, id: my_wiki.id
       expect(assigns(:wiki)).to eq(my_wiki)
     end
   end

   describe "GET #show for private wiki" do
     it "returns http redirect" do
       get :show, id: my_private_wiki.id
       expect(response).to redirect_to(wikis_path)
     end
   end

   describe "GET new" do
        it "returns http redirect" do
            get :new
            expect(response).to redirect_to(new_user_session_path)
        end
    end

    describe "POST create" do
        it "returns http redirect" do
            post :create, wiki: {title: RandomData.random_sentence, body: RandomData.random_paragraph}
            expect(response).to redirect_to(new_user_session_path)
        end
    end

    describe "GET edit" do
        it "returns http redirect" do
            get :edit, {id: my_wiki.id}
            expect(response).to redirect_to(new_user_session_path)
        end
    end

    describe "PUT update" do
        it "returns http redirect" do
            new_title = RandomData.random_sentence
            new_body = RandomData.random_paragraph

            put :update, id: my_wiki.id, wiki: {title: new_title, body: new_body }
            expect(response).to redirect_to(new_user_session_path)
        end
    end

    describe "DELETE destroy" do
        it "doesn't delete the wiki" do
          delete :destroy, id: my_wiki.id
          count = Wiki.where(id: my_wiki.id).size
          expect(count).to eq(1)
        end

        it "returns http redirect" do
            delete :destroy, {id: my_wiki.id}
            expect(response).to redirect_to(new_user_session_path)
        end
    end

  end

 context "standard user for wiki they own" do
    before do
        @user = my_user
        @user.confirmed_at = Time.zone.now
        @user.save
        @request.env["devise.mapping"] = Devise.mappings[:user]
        sign_in @user
        #my_wiki.creator = @user
    end

    it "expects user role to be standard" do
      expect(@user.role).to eq("standard")
    end

  describe "GET #index" do

    it "returns http success" do
      get :index
      expect(response).to have_http_status(:success)
    end

    it "renders the #index view" do
      get :index
      expect(response).to render_template :index
    end

  end

  describe "GET #show" do
    it "returns http success" do
      get :show, id: my_wiki.id
      expect(response).to have_http_status(:success)
    end

    it "renders the #show view" do
      get :show, id: my_wiki.id
      expect(response).to render_template :show
    end

    it "assigns wiki to @wikis" do
      get :show, id: my_wiki.id
      expect(assigns(:wiki)).to eq(my_wiki)
    end
  end

  describe "GET #new" do
    it "returns http success" do
      get :new
      expect(response).to have_http_status(:success)
    end

    it "renders the #new view" do
      get :new
      expect(response).to render_template :new
    end

    it "initializes @wiki" do
      get :new
      expect(assigns(:wiki)).not_to be_nil
    end
  end

  describe "POST #create" do
    it "increases the number of wikis by 1" do
      expect{post :create, wiki: {title: RandomData.random_sentence, body: RandomData.random_paragraph} }.to change(Wiki,:count).by(1)
    end

    it "assigns Wiki.last to @wiki" do
      post :create, wiki: {title: RandomData.random_sentence, body: RandomData.random_paragraph}
      expect(assigns(:wiki)).to eq Wiki.last
    end

    it "redirects to the new wiki" do
      post :create, wiki: {title: RandomData.random_sentence, body: RandomData.random_paragraph}
      expect(response).to redirect_to Wiki.last
    end
  end

  describe "GET #edit" do
    it "returns http success" do
      get :edit, id: my_wiki.id
      expect(response).to have_http_status(:success)
    end

    it "renders the #edit view" do
      get :edit, id: my_wiki.id
      expect(response).to render_template :edit
    end

    it "assigns wiki to be updated to @wiki" do
      get :edit, {id: my_wiki.id}
      wiki_instance = assigns(:wiki)

      expect(wiki_instance.id).to eq my_wiki.id
      expect(wiki_instance.title).to eq my_wiki.title
      expect(wiki_instance.body).to eq my_wiki.body
    end
  end

  describe "PUT #update" do
    it "updates wiki with expected attributes" do
      new_title = RandomData.random_sentence
      new_body = RandomData.random_paragraph

      put :update, id: my_wiki.id, wiki: {title: new_title, body: new_body}

      updated_wiki = assigns(:wiki)
      expect(updated_wiki.id).to eq my_wiki.id
      expect(updated_wiki.title).to eq new_title
      expect(updated_wiki.body).to eq new_body
    end

    it "redirects to the updated wiki" do
      new_title = RandomData.random_sentence
      new_body = RandomData.random_paragraph

      put :update, id: my_wiki.id, wiki: {title: new_title, body: new_body}
      expect(response).to have_http_status(:success)
    end
  end

  describe "DELETE destroy" do
    it "deletes the wiki" do
      delete :destroy, id: my_wiki.id
      count = Wiki.where(id: my_wiki.id).size
      expect(count).to eq(0)
    end

    it "redirects to the index view" do
      delete :destroy, id: my_wiki.id
      expect(response).to redirect_to wikis_path
    end
  end
end

context "standard user for public wiki they don't own" do
   before do
       @user = my_user
       @user.confirmed_at = Time.zone.now
       @user.save
       @request.env["devise.mapping"] = Devise.mappings[:user]
       sign_in @user
   end

   it "expects user role to be standard" do
     expect(@user.role).to eq("standard")
   end

 describe "GET #show" do
   it "returns http success" do
     get :show, id: other_wiki.id
     expect(response).to have_http_status(:success)
   end

   it "renders the #show view" do
     get :show, id: other_wiki.id
     expect(response).to render_template :show
   end

   it "assigns wiki to @wikis" do
     get :show, id: other_wiki.id
     expect(assigns(:wiki)).to eq(other_wiki)
   end
 end

 describe "GET #edit" do
   it "returns http success" do
     get :edit, id: other_wiki.id
     expect(response).to have_http_status(:success)
   end

   it "renders the #edit view" do
     get :edit, id: other_wiki.id
     expect(response).to render_template :edit
   end

   it "assigns wiki to be updated to @wiki" do
     get :edit, {id: other_wiki.id}
     wiki_instance = assigns(:wiki)

     expect(wiki_instance.id).to eq other_wiki.id
     expect(wiki_instance.title).to eq other_wiki.title
     expect(wiki_instance.body).to eq other_wiki.body
   end
 end

 describe "PUT #update" do
   it "updates wiki with expected attributes" do
     new_title = RandomData.random_sentence
     new_body = RandomData.random_paragraph

     put :update, id: other_wiki.id, wiki: {title: new_title, body: new_body}

     updated_wiki = assigns(:wiki)
     expect(updated_wiki.id).to eq other_wiki.id
     expect(updated_wiki.title).to eq new_title
     expect(updated_wiki.body).to eq new_body
   end

   it "redirects to the updated wiki" do
     new_title = RandomData.random_sentence
     new_body = RandomData.random_paragraph

     put :update, id: other_wiki.id, wiki: {title: new_title, body: new_body}
     expect(response).to have_http_status(:success)
   end
 end

 describe "DELETE destroy" do
     it "doesn't delete the wiki" do
       delete :destroy, id: other_wiki.id
       count = Wiki.where(id: other_wiki.id).size
       expect(count).to eq(1)
     end

     it "returns http redirect" do
         delete :destroy, {id: other_wiki.id}
         expect(response).to redirect_to(wikis_path)
     end
 end
end

context "standard user for private wiki they don't own" do
   before do
       @user = my_user
       @user.confirmed_at = Time.zone.now
       @user.save
       @request.env["devise.mapping"] = Devise.mappings[:user]
       sign_in @user
   end

   it "expects user role to be standard" do
     expect(@user.role).to eq("standard")
   end

 describe "GET #show" do
   it "returns http redirect" do
     get :show, id: other_private_wiki.id
     expect(response).to redirect_to(wikis_path)
   end
 end

 describe "GET #edit" do
   it "returns http redirect" do
     get :edit, id: other_private_wiki.id
     expect(response).to redirect_to(wikis_path)
   end
 end

 describe "PUT #update" do
   it "redirects to wikis path" do
     new_title = RandomData.random_sentence
     new_body = RandomData.random_paragraph

     put :update, id: other_private_wiki.id, wiki: {title: new_title, body: new_body}
     expect(response).to redirect_to(wikis_path)
   end
 end

 describe "DELETE destroy" do
     it "doesn't delete the wiki" do
       delete :destroy, id: other_private_wiki.id
       count = Wiki.where(id: other_private_wiki.id).size
       expect(count).to eq(1)
     end

     it "returns http redirect" do
         delete :destroy, {id: other_private_wiki.id}
         expect(response).to redirect_to(wikis_path)
     end
 end
end

context "standard user collaborator for private wiki" do
   before do
       @user = my_user
       @user.confirmed_at = Time.zone.now
       @user.save
       @request.env["devise.mapping"] = Devise.mappings[:user]
       sign_in @user
       other_private_wiki.collaborators << @user
   end

   it "expects user role to be standard" do
     expect(@user.role).to eq("standard")
   end

   describe "add collaborator" do
       it "should add collaborator to wiki" do
         expect(other_private_wiki.collaborators).to include(@user)
       end

       it "should change the size" do
         expect(other_private_wiki.collaborators.size).to eq(1)
       end
   end

 describe "GET #show" do
   it "returns http success" do
     get :show, id: other_private_wiki.id
     expect(response).to have_http_status(:success)
   end

   it "renders the #show view" do
     get :show, id: other_private_wiki.id
     expect(response).to render_template :show
   end

   it "assigns wiki to @wikis" do
     get :show, id: other_private_wiki.id
     expect(assigns(:wiki)).to eq(other_private_wiki)
   end
 end

 describe "GET #edit" do
   it "returns http success" do
     get :edit, id: other_private_wiki.id
     expect(response).to have_http_status(:success)
   end

   it "renders the #edit view" do
     get :edit, id: other_private_wiki.id
     expect(response).to render_template :edit
   end

   it "assigns wiki to be updated to @wiki" do
     get :edit, {id: other_private_wiki.id}
     wiki_instance = assigns(:wiki)

     expect(wiki_instance.id).to eq other_private_wiki.id
     expect(wiki_instance.title).to eq other_private_wiki.title
     expect(wiki_instance.body).to eq other_private_wiki.body
   end
 end

 describe "PUT #update" do
   it "updates wiki with expected attributes" do
     new_title = RandomData.random_sentence
     new_body = RandomData.random_paragraph

     put :update, id: other_private_wiki.id, wiki: {title: new_title, body: new_body}

     updated_wiki = assigns(:wiki)
     expect(updated_wiki.id).to eq other_private_wiki.id
     expect(updated_wiki.title).to eq new_title
     expect(updated_wiki.body).to eq new_body
   end

   it "redirects to the updated wiki" do
     new_title = RandomData.random_sentence
     new_body = RandomData.random_paragraph

     put :update, id: other_private_wiki.id, wiki: {title: new_title, body: new_body}
     expect(response).to have_http_status(:success)
   end
 end

 describe "DELETE destroy" do
     it "doesn't delete the wiki" do
       delete :destroy, id: other_private_wiki.id
       count = Wiki.where(id: other_private_wiki.id).size
       expect(count).to eq(1)
     end

     it "returns http redirect" do
         delete :destroy, {id: other_private_wiki.id}
         expect(response).to redirect_to(wikis_path)
     end
 end
end

context "admin user for private wiki they don't own" do
   before do
       @user = admin_user
       @user.confirmed_at = Time.zone.now
       @user.save
       @request.env["devise.mapping"] = Devise.mappings[:user]
       sign_in @user
   end

   it "expects user role to be standard" do
     expect(@user.role).to eq("admin")
   end

 describe "GET #show" do
   it "returns http success" do
     get :show, id: other_private_wiki.id
     expect(response).to have_http_status(:success)
   end

   it "renders the #show view" do
     get :show, id: other_private_wiki.id
     expect(response).to render_template :show
   end

   it "assigns wiki to @wikis" do
     get :show, id: other_private_wiki.id
     expect(assigns(:wiki)).to eq(other_private_wiki)
   end
 end

 describe "GET #edit" do
   it "returns http success" do
     get :edit, id: other_private_wiki.id
     expect(response).to have_http_status(:success)
   end

   it "renders the #edit view" do
     get :edit, id: other_private_wiki.id
     expect(response).to render_template :edit
   end

   it "assigns wiki to be updated to @wiki" do
     get :edit, {id: other_private_wiki.id}
     wiki_instance = assigns(:wiki)

     expect(wiki_instance.id).to eq other_private_wiki.id
     expect(wiki_instance.title).to eq other_private_wiki.title
     expect(wiki_instance.body).to eq other_private_wiki.body
   end
 end

 describe "PUT #update" do
   it "updates wiki with expected attributes" do
     new_title = RandomData.random_sentence
     new_body = RandomData.random_paragraph

     put :update, id: other_private_wiki.id, wiki: {title: new_title, body: new_body}

     updated_wiki = assigns(:wiki)
     expect(updated_wiki.id).to eq other_private_wiki.id
     expect(updated_wiki.title).to eq new_title
     expect(updated_wiki.body).to eq new_body
   end

   it "redirects to the updated wiki" do
     new_title = RandomData.random_sentence
     new_body = RandomData.random_paragraph

     put :update, id: other_private_wiki.id, wiki: {title: new_title, body: new_body}
     expect(response).to have_http_status(:success)
   end
 end

 describe "DELETE destroy" do
   it "deletes the wiki" do
     delete :destroy, id: other_private_wiki.id
     count = Wiki.where(id: other_private_wiki.id).size
     expect(count).to eq(0)
   end

   it "redirects to the index view" do
     delete :destroy, id: other_private_wiki.id
     expect(response).to redirect_to wikis_path
   end
 end
end

context "premium user for wiki they own" do
   before do
       @user = premium_user
       @user.confirmed_at = Time.zone.now
       @user.save
       @request.env["devise.mapping"] = Devise.mappings[:user]
       sign_in @user
   end

   it "expects user role to be premium" do
     expect(@user.role).to eq("premium")
   end

 describe "GET #show" do
   it "returns http success" do
     get :show, id: my_private_wiki.id
     expect(response).to have_http_status(:success)
   end

   it "renders the #show view" do
     get :show, id: my_private_wiki.id
     expect(response).to render_template :show
   end

   it "assigns wiki to @wikis" do
     get :show, id: my_private_wiki.id
     expect(assigns(:wiki)).to eq(my_private_wiki)
   end
 end

 describe "GET #new" do
   it "returns http success" do
     get :new
     expect(response).to have_http_status(:success)
   end

   it "renders the #new view" do
     get :new
     expect(response).to render_template :new
   end

   it "initializes @wiki" do
     get :new
     expect(assigns(:wiki)).not_to be_nil
   end
 end

 describe "POST #create" do
   it "increases the number of wikis by 1" do
     expect{post :create, wiki: {title: RandomData.random_sentence, body: RandomData.random_paragraph} }.to change(Wiki,:count).by(1)
   end

   it "assigns Wiki.last to @wiki" do
     post :create, wiki: {title: RandomData.random_sentence, body: RandomData.random_paragraph}
     expect(assigns(:wiki)).to eq Wiki.last
   end

   it "redirects to the new wiki" do
     post :create, wiki: {title: RandomData.random_sentence, body: RandomData.random_paragraph}
     expect(response).to redirect_to Wiki.last
   end
 end

 describe "GET #edit" do
   it "returns http success" do
     get :edit, id: my_private_wiki.id
     expect(response).to have_http_status(:success)
   end

   it "renders the #edit view" do
     get :edit, id: my_private_wiki.id
     expect(response).to render_template :edit
   end

   it "assigns wiki to be updated to @wiki" do
     get :edit, {id: my_private_wiki.id}
     wiki_instance = assigns(:wiki)

     expect(wiki_instance.id).to eq my_private_wiki.id
     expect(wiki_instance.title).to eq my_private_wiki.title
     expect(wiki_instance.body).to eq my_private_wiki.body
   end
 end

 describe "PUT #update" do
   it "updates wiki with expected attributes" do
     new_title = RandomData.random_sentence
     new_body = RandomData.random_paragraph

     put :update, id: my_private_wiki.id, wiki: {title: new_title, body: new_body}, collaborator_email: collaborator.email

     updated_wiki = assigns(:wiki)
     expect(updated_wiki.id).to eq my_private_wiki.id
     expect(updated_wiki.title).to eq new_title
     expect(updated_wiki.body).to eq new_body
     expect(updated_wiki.collaborators.size).to eq(1)
     expect(updated_wiki.collaborators).to include(collaborator)

   end

   it "redirects to the updated wiki" do
     new_title = RandomData.random_sentence
     new_body = RandomData.random_paragraph

     put :update, id: my_private_wiki.id, wiki: {title: new_title, body: new_body}
     expect(response).to have_http_status(:success)
   end
 end

 describe "DELETE destroy" do
   it "deletes the wiki" do
     delete :destroy, id: my_private_wiki.id
     count = Wiki.where(id: my_private_wiki.id).size
     expect(count).to eq(0)
   end

   it "redirects to the index view" do
     delete :destroy, id: my_private_wiki.id
     expect(response).to redirect_to wikis_path
   end
 end
end

  describe "scopes" do
     before do
       @user = User.new(email: "user@example.com", password: "password")
       @public_wiki = Wiki.create!(title: RandomData.random_sentence, body: RandomData.random_paragraph, private: false, creator: @user)
       @private_wiki = Wiki.create!(title: RandomData.random_sentence, body: RandomData.random_paragraph, private: true, creator: @user)
     end

     describe "visible_to(user)" do
       it "returns all wikis if the user is premium" do
         @user.premium!
         expect(Wiki.visible_to(@user)).to eq(Wiki.all)
       end

       it "returns only public wikis if user is standard" do
         @user.standard!
         my_wiki.private = true
         my_wiki.save!
         expect(Wiki.visible_to(@user)).to eq([@public_wiki])
       end

       it "does not return private wikis if user is standard" do
         @user.standard!
         expect(Wiki.visible_to(@user)).to_not eq([@private_wiki])
       end
     end
   end
end
