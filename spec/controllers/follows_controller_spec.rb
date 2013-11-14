require 'spec_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.

describe FollowsController do
  
  before do
    @user = FactoryGirl.create(:user)
    @to_follow = FactoryGirl.create(:user)
    request.env['warden'].stub :authenticate! => @user
    controller.stub :current_or_guest_user => @user
  end

  # This should return the minimal set of attributes required to create a valid
  # Follow. As you add validations to Follow, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    FactoryGirl.attributes_for(:follow).merge(:followed_id => @to_follow.id, :follower_id => @user.id)
  end

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # FollowsController. Be sure to keep this updated too.
  def valid_session
    {}
  end

  describe "Get index" do
    it "assigns all follows as @follows" do
      sign_in @user
      follow = FactoryGirl.create(:follow, :follower => @user)
      get :index, {:user_id => @user}, valid_session
      assigns(:followed).should eq([follow])
    end
  end

  describe "POST create" do 
    describe "with valid params" do
      it "creates a new Follow" do
        expect {
          post :create, { :user_id => @user, :followed_id => @to_follow.id }, valid_session
        }.to change(Follow, :count).by(1)
      end

      it "assigns a newly created follow as @follow" do
        post :create, { :user_id => @user, :followed_id => @to_follow.id }, valid_session
        assigns(:follow).should be_a(Follow)
        assigns(:follow).should be_persisted
      end
      
      it "redirects to the contacts list in dashboard" do
        post :create, { :user_id => @user, :followed_id => @to_follow.id }, valid_session
        response.should redirect_to( dashboard_contacts_url )
      end
    end

    describe "with invalid params" do
      it "will raise an error" 
    end
  end

  

  describe "DELETE destroy" do
    it "destroys the requested follow" do
      follow = Follow.create! valid_attributes
      expect {
        delete :destroy, {:user_id => @user, :id => follow.to_param}, valid_session
      }.to change(Follow, :count).by(-1)
    end
  
    it "redirects to the contacts list in dashboard" do
      follow = Follow.create! valid_attributes
      delete :destroy, {:user_id => @user, :id => follow.to_param}, valid_session
      response.should redirect_to( dashboard_contacts_url )
    end
  end
end
