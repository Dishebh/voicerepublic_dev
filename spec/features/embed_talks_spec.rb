require 'spec_helper'

# it renders specs
describe 'EmbedTalkController' do
  # old school
  it 'it renders show on GET /embed_talk/:id' do
    @talk = FactoryGirl.create(:talk)

    visit embed_talk_path(id: @talk)
    page.should have_selector('.embed_talk-show')
  end

  # new school
  it 'it renders show on GET /embed/:id' do
    @talk = FactoryGirl.create(:talk)
    visit embed_url(@talk)
    page.should have_selector('.embed_talk-show')
  end
end
