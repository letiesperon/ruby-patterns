class Checkout < ApplicationRecord
  include Engageable
  include SmsInteractionable

  belongs_to :shop, optional: true
  belongs_to :customer, optional: true
  belongs_to :engaged_campaign, class_name: 'Campaign', optional: true

  has_one :order, dependent: :destroy
  has_many :messenger_optins, dependent: :destroy
  has_many :messenger_optin_engagements, through: :messenger_optins
  has_many :checkout_engagements, dependent: :destroy
  has_many :engagements, through: :checkout_engagements
  has_many :interactions, as: :interactionable, dependent: :destroy

  validates :shopify_id, presence: true, uniqueness: true

  scope :accepting_sms, -> { where(accepts_sms_marketing: true) }
  scope :not_migrated, -> { where(migrate_status: nil) }
  scope :with_customer, -> { where.not(customer_id: nil) }

  scope(:for_acc_job, lambda do
    joins(:shop)
      .merge(Shop.with_abandoned_cart)
      .where.not(phone: nil)
      .recent.pending
      .accepting_sms
      .not_migrated
  end)

  def order_attributed
    order&.attributed_campaign
  end

  def abandoned_for?(minutes)
    return false unless cart_updated

    (Time.now - cart_updated) / 60 > minutes
  end

  # ...
end
