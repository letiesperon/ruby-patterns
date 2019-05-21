class CheckoutsQuery
  attr_reader :relation

  def initialize(relation = Checkout.all)
    @relation = relation.extending(Scopes)
  end

  def for_acc_job
    relation.joins(:shop)
      .merge(Shop.with_abandoned_cart)
      .where.not(phone: nil)
      .where(accepts_sms_marketing: true)
      .not_migrated
      .pending
      .recent
  end

  def with_customer
    relation.where.not(customer_id: nil)
  end

  private

  module Scopes
    def not_migrated
      where(migrate_status: nil)
    end

    def pending
      where(completed_at: nil, campaign_disabled: false)
    end

    def recent
      where('checkouts.updated_at >= ?', AbandonedCartSetting::DAYS_LIMIT.days.ago)
    end
  end
end
