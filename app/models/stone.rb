class Stone < ActiveRecord::Base
  include HasRecordProperty

  acts_as_taggable
  with_recursive

  has_many :analyses
  has_many :children, class_name: "Stone", foreign_key: :parent_id
  has_many :attachings, as: :attachable
  has_many :referrings, as: :referable
  belongs_to :parent, class_name: "Stone", foreign_key: :parent_id
  belongs_to :box
  belongs_to :place
  belongs_to :classification
  belongs_to :physical_form

  validates :box, existence: true, allow_nil: true
  validates :place, existence: true, allow_nil: true
  validates :classification, existence: true, allow_nil: true
  validates :physical_form, existence: true, allow_nil: true
end
