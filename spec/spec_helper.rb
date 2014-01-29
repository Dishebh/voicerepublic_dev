require 'simplecov'
SimpleCov.start 'rails'

# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
#require 'rspec/autorun'

require 'capybara/rspec'
require 'capybara/rails'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.check_pending! if defined?(ActiveRecord::Migration)

RSpec.configure do |config|

  config.color_enabled = true

  # ## Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr

  # does not work with zeus & specific file
  # config.include FactoryGirl::Syntax::Methods

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"

  # filter only the specs with :focus => true
  config.filter_run :focus => true
  config.run_all_when_everything_filtered = true

  config.include Devise::TestHelpers, :type => :controller
  #config.include Devise::TestHelpers, :type => :feature
  config.include ValidUserRequestHelper, :type => :feature
  #config.include ValidUserRequestHelper, :type => :controller

  # Disable GC and Start Stats
  # disable GC by default
  config.before(:suite) do
    GC.disable
  end

  ## Enable GC
  config.after(:suite) do
    example_counter = 0
    GC.enable
  end

  # Trigger GC after every_nths examples, defaults to 20.
  # Set an appropriate value via config/settings.local.yml
  #
  # (How many specs can your machine ran before it runs out of RAM
  # when GC is turned off?)
  #
  every_nths = Settings.rspec.gc_cycle
  example_counter = 0
  config.after(:each) do
    if example_counter % every_nths == 0
      print 'G'
      GC.enable
      GC.start
      GC.disable
    end
    example_counter += 1
  end

end

module FactoryGirl
  class << self
    def build_attributes(*args)
      FactoryGirl.build(*args).attributes.delete_if do |k, v|
        ["id", "created_at", "updated_at"].member?(k)
      end
    end
  end
end
