class CheckoutsQuery
  attr_reader :relation

  def initialize(relation = Checkout.all)
    @relation = relation
  end

  def for_acc_job
    relation.joins(:shop)
      .merge(Shop.with_abandoned_cart)
      .where.not(phone: nil)
      .where(accepts_sms_marketing: true)
      .where(migrate_status: nil)
      .where(completed_at: nil, campaign_disabled: false)
      .where('checkouts.updated_at >= ?', AbandonedCartSetting::DAYS_LIMIT.days.ago)
  end

  def with_customer
    relation.where.not(customer_id: nil)
  end
end
