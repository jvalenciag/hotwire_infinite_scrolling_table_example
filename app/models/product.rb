class Product < ApplicationRecord
  include PgSearch::Model
  pg_search_scope :search_all,
    against: [ :name, :description ],
    associated_against: { brand: :searchable },
    using: {
      tsearch: {
        tsvector_column: "searchable",
        prefix: true,
        highlight: {
          StartSel: "<b>",
          StopSel: "</b>",
          MaxWords: 123,
          MinWords: 456,
          ShortWord: 4,
          HighlightAll: true,
          MaxFragments: 3,
          FragmentDelimiter: "&hellip;"
        }
      }
    }

  scope :enabled, -> { where(enabled: true) }

  belongs_to :brand
  has_many :product_variants, dependent: :restrict_with_error

  delegate :name, to: :brand, prefix: true
end
