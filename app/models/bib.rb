class Bib < ActiveRecord::Base
  has_many :attachings, as: :attachable
  has_many :referrings, as: :referable
  has_one :record_property, as: :datum
end
