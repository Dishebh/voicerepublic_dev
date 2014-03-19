# Attributes:
# * id [integer, primary, not null] - primary key
# * created_at [datetime] - creation time
# * request_ip [string] - TODO: document me
# * shareable_id [integer] - belongs to :shareable (polymorphic)
# * shareable_type [string] - belongs to :shareable (polymorphic)
# * social_network [string] - TODO: document me
# * updated_at [datetime] - last update time
# * user_agent [string] - TODO: document me
# * user_id [integer] - TODO: document me
class SocialShare < ActiveRecord::Base
  attr_accessible :request_ip, :user_agent, :user_id, :shareable_id,
    :shareable_type, :social_network

  belongs_to :shareable, polymorphic: true

  validates :shareable_type, inclusion: %w(talk venue)
end
