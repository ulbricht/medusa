class Group < ActiveRecord::Base
  has_many :group_members
  has_many :users, through: :group_members
  has_many :record_properties

  validates :name, presence: true, length: { maximum: 255 }
end
