module AbandonedCartCampaign
  class QueueMessagesJob < ApplicationJob
    # ...

    def enqueue_checkouts_sms
      @target_checkouts = CheckoutsQuery.new.for_acc_job

      target_checkouts.find_each do |checkout|
        SendSmsJob.perform_later(checkout.id)
      end
    end

    def enqueue_product_abandonment_sms
      target_shops = Shop.with_feature_enabled(:product_abandonment)
      target_shops_customers = Customer.where(shop: target_shops)
      already_targeted_customers = CheckoutsQuery.new(target_checkouts).with_customer.select(:customer_id)

      target_shops_customers.for_acc_job.exclude(already_targeted_customers).find_each do |customer|
        SendProductSmsJob.perform_later(customer.id)
      end
    end

    # ...
  end
end
