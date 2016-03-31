# Read about factories at https://github.com/thoughtbot/factory_girl

# TODO why is this here?
include ActionDispatch::TestProcess

# Good to know when using FactoryGirl with Spring: Changes to the
# factories will only be picked up after you stopped spring!
#
FactoryGirl.define do

  factory :series do
    title 'Series title'
    user
  end

  factory :venue do
    name "Some venue"
    user
    trait :provisioning do
      state :provisioning
      client_token 'free-your-mind'
    end
    trait :ready do
      state :ready
      public_ip_address '0.0.0.0'
      mount_point 'random-mountpoint'
      source_password 'some-password'
    end
    trait :connected do
      state :connected
    end
  end

  sequence :email do |n|
    "hans#{n}@example.com"
  end

  factory :admin_user do
  end

  # the default user is a confirmed user, if you need an unconfirmed
  # user use the trait `unconfirmed`, as in...
  #
  #   FactoryGirl.create(:user, :unconfirmed)
  #
  factory :user do
    ignore do
      unconfirmed false
    end

    firstname 'Hans'
    lastname 'Hanebambel'
    email
    last_request_at { Time.now }
    password secret = "mysecret"
    password_confirmation secret
    timezone 'Berlin'

    trait :with_credits do
      credits 3
    end

    trait :unconfirmed do
      unconfirmed true
    end

    after :create do |user, evaluator|
      user.confirm! unless evaluator.unconfirmed
    end
  end

  factory :participation do
    series
    user
  end

  factory :talk do
    title "Some awesome title"
    series
    # NOTE: times set here are not affected by `Timecop.freeze` in a
    # `before` block
    starts_at_time 1.hour.from_now.strftime('%H:%M')
    starts_at_date 1.hour.from_now.strftime('%Y-%m-%d')
    duration 60
    tag_list 'lorem, ipsum, dolor'
    description 'Some talk description'
    language 'en'

    trait :archived do
      state 'archived'
      processed_at { 2.hours.ago }
    end

    trait :featured do
      featured_from { 1.day.ago }
    end

    trait :popular do
      play_count 25
    end

    trait :with_user_override_uuid do
      user_override_uuid "http://s3.amazon.com/fake_bucket/nothing_here"
      starts_at_time 1.hour.ago.strftime('%H:%M')
      starts_at_date 1.hour.ago.strftime('%Y-%m-%d')
    end
  end

  factory :appearance do
    user
    talk
  end

  factory :message do
    user
    talk
    content "MyText"
  end

  factory :setting do
    key "MyString"
    value "MyString"
  end

  factory :tag, :class => ActsAsTaggableOn::Tag do |f|
    f.sequence(:name) { |n| "tag_#{n}" }
  end

  factory :reminder do
    user
    rememberable nil
  end


  factory :purchase do
    owner factory: :user
    product Pricing::BUSINESS.first
    country 'CH'
  end

  factory :purchase_transaction do
    association :source, factory: :purchase
  end

  factory :tag_bundle do
    title_en "MyString"
    title_de "MyString"
  end

  factory :device do
    identifier "MyString"
    type ""
    subtype "MyString"
    name "MyString"
    state "MyString"
    last_heartbeat_at "2016-03-19 20:32:44"
    organization_id nil
    paired_at "2016-03-19 20:32:44"
  end

  factory :organization do
    name "MyString"
    slug "MyString"
    credits 1
    image_uid "MyString"
    image_name "MyString"
    image_alt "MyString"
    logo_uid "MyString"
    logo_name "MyString"
    logo_alt "MyString"
    description "MyText"
    description_as_html "MyText"
    description_as_text "MyText"
    website "MyString"
    penalty 1.5
    paying false
    featured_from "2016-03-19 20:29:10"
    featured_until "2016-03-19 20:29:10"
  end

  factory :membership do
    user nil
    organization nil
  end

end
