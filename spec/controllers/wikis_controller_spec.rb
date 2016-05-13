require 'rails_helper'
require 'random_data'

RSpec.describe WikisController, type: :controller do

  let(:my_user) { FactoryGirl.create(:user)}
  #let(:my_user) { User.create!(email: "my_user@example.com", password: "password")}
  let(:my_wiki) { Wiki.create!(title: "New Wiki Title", body: "New Wiki Body", private: false) }
  let(:my_private_wiki) { Wiki.create!(title: "New Wiki Title", body: "New Wiki Body", private: true) }

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

     it "assigns wiki to @wikis" do
       get :index
       expect(assigns(:wikis)).to eq([my_wiki])
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
        it "returns http redirect" do
            delete :destroy, {id: my_wiki.id}
            expect(response).to redirect_to(new_user_session_path)
        end
    end

    it "does not include private wikis in @wikis" do
        get :index
        expect(assigns(:wikis)).not_to include(my_private_wiki)
    end

  end

 context "standard user" do
    before do
        #user = User.create!(email: "user@bloccit.com", password: "helloworld", role: :standard)
        user = my_user
        user.confirmed_at = Time.zone.now
        user.save
        @request.env["devise.mapping"] = Devise.mappings[:user]
        sign_in user
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

    it "assigns wiki to @wikis" do
      get :index
      expect(assigns(:wikis)).to eq([my_wiki])
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

  describe "scopes" do
     before do
       @user = User.new(email: "user@example.com", password: "password")
       @public_wiki = Wiki.create!(title: RandomData.random_sentence, body: RandomData.random_paragraph, private: false, user: @user)
       @private_wiki = Wiki.create!(title: RandomData.random_sentence, body: RandomData.random_paragraph, private: true, user: @user)
     end

     describe "visible_to(user)" do
       it "returns all wikis if the user is premium" do
         @user.premium!
         expect(Wiki.visible_to(@user)).to eq(Wiki.all)
       end

       it "returns only public wikis if user is standard" do
         @user.standard!
         expect(Wiki.visible_to(@user)).to eq([@public_wiki])
       end

       it "does not return private wikis if user is standard" do
         @user.standard!
         expect(Wiki.visible_to(@user)).to_not eq([@private_wiki])
       end
     end
   end
 end
end
