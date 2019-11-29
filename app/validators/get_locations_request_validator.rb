class GetLocationsRequestValidator < BaseValidator
  validates :warehouse_id, numericality: { greater_than: 0 }
  validates :fake, presence: true
end