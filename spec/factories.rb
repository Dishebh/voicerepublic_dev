# Read about factories at https://github.com/thoughtbot/factory_girl

# TODO why is this here?
include ActionDispatch::TestProcess

# Good to know when using FactoryGirl with Spring: Changes to the
# factories will only be picked up after you stopped spring!
#
FactoryGirl.define do
  factory :artifact do
    url "MyString"
    context_type "MyString"
    context_id 1
    size 1
    content_type "MyString"
  end
  factory :job do
    details "---\n{}"
  end
  factory :instance do
  end
  factory :event do
    name "MyString"
    source_type "MyString"
    source_id 1
  end
  factory :device_report do
    device nil
    data "MyText"
  end

  factory :series do
    title 'Series title'
    user
  end

  sequence :client_token do |n|
    "client-token-#{n}"
  end

  factory :venue do
    name "Some venue"
    user
    trait :available do
      state :available
    end
    trait :provisioning do
      state :provisioning
      client_token
    end
    trait :device_required do
      state :device_required
    end
    trait :awaiting_stream do
      state :awaiting_stream
      client_token
      public_ip_address '0.0.0.0'
      mount_point 'random-mountpoint'
      source_password 'some-password'
    end
    trait :connected do
      state :connected
      client_token
    end
    trait :disconnect_required do
      state :disconnect_required
    end
    trait :disconnected do
      state :disconnected
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
    transient do
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
    venue

    # NOTE: this is tricky & ugly
    after :create  do |talk|
      talk.venue.update_attribute(:user_id, talk.user.id)
    end

    # NOTE: times set here are not affected by `Timecop.freeze` in a
    # `before` block
    starts_at_time 1.hour.from_now.strftime('%H:%M')
    starts_at_date 1.hour.from_now.strftime('%Y-%m-%d')
    duration 60
    tag_list 'lorem, ipsum, dolor'
    description 'Some talk description'
    language 'en'

    trait :prelive do
      state 'prelive'
      starts_at 10.minutes.from_now
    end

    trait :live do
      state 'live'
    end

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
    identifier "some-identifier"
  end


  factory :organization do
    name "My Organization"
    slug "my-organization"
  end


  factory :membership do
    user
    organization
  end

end
