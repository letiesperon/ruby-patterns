# controller
@shop = Shop.new(params[:shop])
@shop = ShopWithTwilio.new(@shop)
@shop = ShopWithFeatureSettings.new(@shop)
@shop = ShopWithSegments.new(@shop)
@shop.save

# models/shop.rb
class Shop < ApplicationRecord
  # ...
end

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

# decorators/shop_with_feature_settings.rb
class ShopWithFeatureSettings
  def initialize(shop)
    @shop = shop
  end

  def save
    @shop.save && initialize_associated_feature_setting
  end

  private

  def initialize_associated_feature_setting
    @shop.build_feature_setting
  end
end

# decorators/shop_with_segments.rb
class ShopWithSegments
  def initialize(shop)
    @shop = shop
  end

  def save
    @shop.save && initialize_associated_feature_setting
  end

  private

  def initialize_associated_feature_setting
    Segment.predefined.find_each do |segment|
      @shop.shop_segments.new(segment: segment)
    end
  end
end

