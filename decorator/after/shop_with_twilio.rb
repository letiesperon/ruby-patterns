# decorators/shop_with_twilio.rb
class ShopWithTwilio
  def initialize(shop)
    @shop = shop
  end

  def save
    @shop.save && create_twilio_subaccount
  end

  private

  def create_twilio_subaccount
    if Rails.env.test?
      @shop.twilio_subaccount_sid = ENV['TWILIO_SUBACCOUNT_TEST_SID']
    else
      TwilioService.new(self).setup_twilio_configuration
    end
  end
end
