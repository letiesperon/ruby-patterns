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
