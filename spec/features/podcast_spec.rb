require 'spec_helper'

feature 'Podcast' do

  let(:rss) { '//link[@rel="alternate"][@type="application/rss+xml"]' }

  feature 'for root on landing_page#index' do

    scenario 'link to rss in head' do
      visit root_path
      links = Nokogiri::HTML(source).xpath(rss)
      expect(links).to_not be_empty
    end

    scenario 'landing_page#index.rss' do
      visit root_path(format: 'rss')
      page.should have_xpath('//rss')
    end

  end

  feature 'for user on users#show' do

    let(:user) { FactoryGirl.create(:user) }

    scenario 'link to rss in head' do
      visit user_path(user)
      links = Nokogiri::HTML(source).xpath(rss)
      expect(links).to_not be_empty
    end

    scenario 'users#show.rss' do
      user = FactoryGirl.create(:user)
      visit user_path(user, format: 'rss')
      page.should have_xpath('//rss')
    end

  end

  feature 'for venue on venues#show' do

    let(:venue) { FactoryGirl.create(:venue) }

    scenario 'venues#show' do
      visit venue_path(venue)
      links = Nokogiri::HTML(source).xpath(rss)
      expect(links).to_not be_empty
    end

    scenario 'venues#show.rss' do
      visit venue_path(venue, format: 'rss')
      page.should have_xpath('//rss')
    end

  end

  feature 'for all podcasts' do
    scenario 'there is a embed link in item' do
      # prepare
      talk = FactoryGirl.create(:talk, state: 'archived', featured_from: 1.day.ago)
      # fake the presence of a suitable file for podcasting
      talk.storage["#{talk.uri}/#{talk.id}.mp3"] = {}
      talk.save
      
      # visit
      visit root_path(format: 'rss')
      expect(page).to have_xpath("//link[@rel='embed']")
    end
  end
  
  feature "different OSs see different protocol URLs" do

    let(:venue) { FactoryGirl.create(:venue) }

    describe "ITPC protocol" do
      scenario "safari 7" do
        user_agent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9) AppleWebKit/537.71"+
                     " (KHTML, like Gecko) Version/7.0 Safari/537.71"
        page.driver.browser.header('User-Agent', user_agent)
        visit venue_path(venue)
        page.should have_xpath("//a[contains(@href,'itpc')]")
      end
      scenario "iPad" do
        user_agent = "Mozilla/5.0 (iPad; CPU OS 6_0 like Mac OS X) AppleWebKit/536.26"+
                     " (KHTML, like Gecko) Version/6.0 Mobile/10A5355d Safari/8536.25"
        page.driver.browser.header('User-Agent', user_agent)
        visit venue_path(venue)
        page.should have_xpath("//a[contains(@href,'feed')]")
      end
      scenario "iPad" do
        user_agent = "Mozilla/5.0 (iPhone; U; ru; CPU iPhone OS 4_2_1 like Mac OS X;"+
                     " ru) AppleWebKit/533.17.9 (KHTML, like Gecko) Version/5.0.2"+
                     " Mobile/8C148a Safari/6533.18.5"
        page.driver.browser.header('User-Agent', user_agent)
        visit venue_path(venue)
        page.should have_xpath("//a[contains(@href,'feed')]")
      end
      scenario "Firefox/Linux" do
        user_agent = "Mozilla/5.0 (X11; Linux x86_64; rv:28.0) Gecko/20100101"+
                     " Firefox/28.0"
        page.driver.browser.header('User-Agent', user_agent)
        visit venue_path(venue)
        xpath = "//a[contains(@href,'http://www.example.com/"+
                "venues/#{venue.to_param}.rss')]"
        page.should have_xpath(xpath)
      end
    end

  end

end
