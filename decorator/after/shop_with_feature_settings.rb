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
