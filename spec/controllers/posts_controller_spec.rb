require 'rails_helper'

RSpec.describe PostsController, type: :controller do
  let(:user) { create(:user) } # create() is a method from FactoryGirl
  let(:post_1) { create(:post, user: user) }
  let(:post_2) { create(:post, user: user)}

  # In case I need a vanilla method for logging in the user:
  # def login(user)
  #   request.session[:user_id] = user.id
  # end

  describe "#create," do
    context "user is signed in," do
      before { sign_in(user) } # sign_in is a method from Devise
      context "with valid parameters," do
        def valid_request
          post :create, { post: {title: "Hello There", user_id: user }}
          # user # Calls the method let(:user)
          # login(user)
          # post_2 # Calls the method let(:post_2)
        end

        it "creates a new post" do
          expect { valid_request }.to change {Post.count}.by(1)
        end # it "creates a new post"

        it "redirects to index page" do
          valid_request
          expect(response).to redirect_to(posts_path)
        end

        it "creates a flash notice" do
          valid_request
          expect(flash[:notice]).to eq("Post successfully saved!")
        end

      end # context "with valid parameters"

      context "withOUT valid parameters," do
        def invalid_request
          post :create, { post: {title: nil, user_id: user }}
        end

        it "does NOT add a new record in database" do
          expect{invalid_request}.to change {Post.count}.by(0)
        end

        it "renders the 'new post' page" do
          invalid_request
          expect(response).to render_template(:new)
        end

        it "creates a flash alert" do
          invalid_request
          expect(flash[:alert]).to eq("We could not post your blog")
        end

      end # context "withOUT valid parameters"

    end # context "user is signed in: "

  end # describe "#create"

  describe "#update," do
    context "user is signed in," do
      before { sign_in(user) }
        context "with valid parameters," do
          before do
            patch :update, id: post_1.id, post: {title: "some new title", body: "some new body", user_id: user}
          end # before do: update existing record

          it "updates the record with a new title" do
            expect(post_1.reload.title).to eq("some new title")
          end # it updates with new values

          it "updates the record with a new body" do
            expect(post_1.reload.body).to eq("some new body")
          end # it updates with new values

          it "redirects to the post's 'show' page" do
            expect(response). to redirect_to(post_path(post_1))
          end # it redirects to "show" page

          it "renders a flash message" do
            expect(flash[:notice]).to eq("Post successfully updated!")
          end # it renders a flash message
        end # context "with valid parameters,"

        context "withOUT valid parameters," do
          before do
            patch :update, id: post_1.id, post: {title: nil}
          end

          it "the record's values stay the same" do
            expect(post_1.reload.title).to include("I am a title")
          end # it: the record's values stay the same

          it "renders the 'edit' page" do
            expect(response).to render_template(:edit)
          end # it: renders the "edit" page

          it "renders a flash alert message" do
            expect(flash[:alert]).to eq("We could not update this post.")
          end # it: renders a flash alert message
        end # context: withOUT valid parameters
    end # context "user is signed in"
  end # describe "#update"

end # RSpec.describe