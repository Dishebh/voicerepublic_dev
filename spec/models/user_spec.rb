# encoding: utf-8
require 'spec_helper'

describe User do

  it "has a valid factory" do
    FactoryGirl.create(:user).should be_valid
  end
  it "is invalid without an email" do
    FactoryGirl.build(:user, email: nil).should_not be_valid
  end
  it "is invalid without firstname" do
    FactoryGirl.build(:user, firstname: nil).should_not be_valid
  end
  it "is invalid without lastname" do
    FactoryGirl.build(:user, lastname: nil).should_not be_valid
  end

  describe 'determines its role to a given talk' do
    let(:user) { FactoryGirl.create(:user) }
    it 'detects being a host' do
      venue = FactoryGirl.create(:venue, user: user)
      talk = FactoryGirl.create(:talk, venue: venue)
      expect(user.role_for(talk)).to be(:host)
    end
    it 'detects being a guest' do
      talk = FactoryGirl.create(:talk)
      FactoryGirl.create(:appearance, user: user, talk: talk)
      expect(user.role_for(talk)).to be(:guest)
    end
    it 'detects being a participant' do
      talk = FactoryGirl.create(:talk)
      FactoryGirl.create(:participation, user: user, venue: talk.venue)
      expect(user.role_for(talk)).to be(:participant)
    end
    it 'detects being a listener' do
      talk = FactoryGirl.create(:talk)
      expect(user.role_for(talk)).to be(:listener)
    end
  end

  describe 'search' do
    it 'has a scope' do
      user0 = FactoryGirl.create(:user, firstname: 'MrBruce')
      user1 = FactoryGirl.create(:user, lastname: 'MrBruce')
      user2 = FactoryGirl.create(:user, firstname: 'Mr', lastname: 'Bruce')
      results = User.search('MrBruce')
      results.should include(user0)
      results.should include(user1)
      results.should_not include(user2)
    end

    it 'ignores accents' do
      user = FactoryGirl.create(:user, firstname: 'MrBrùce')

      # searching for a user with accent works without writing it
      results = User.search('MrBruce')
      results.should include(user)

      # searching for a user with wrong accents works
      results = User.search('MrBrucè')
      results.should include(user)
    end
  end

end
