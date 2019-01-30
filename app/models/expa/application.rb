class Expa::Application < ApplicationRecord
  scope :first_approved_at, -> { approveds.order(:approved_at).first }
  scope :approveds, -> { where.not(approved_at: nil) }
  scope :synchronized_approveds, -> { approveds.where.not(podio_id: nil) }

  belongs_to :exchange_participant, foreign_key: :exchange_participant_id, optional: true

  validates :product, presence: true

  enum product: %i[gv ge gt]

  enum status: { open: 1, applied: 2, accepted: 3, approved_tn_manager: 4, approved_ep_manager: 5, approved: 6,
            break_approved: 7, rejected: 8, withdrawn: 9,
            realized: 100, approval_broken: 101, realization_broken: 102, matched: 103,
            completed: 104 }
end
