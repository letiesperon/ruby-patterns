# models/shop.rb
class Shop < ApplicationRecord
  #...
  after_create :initialize_twilio, :initialize_feature_setting, :add_predefined_segments
  #...

  private

  def initialize_twilio
    if Rails.env.test?
      update(twilio_subaccount_sid: ENV['TWILIO_SUBACCOUNT_TEST_SID'])
    else
      TwilioService.new(self).setup_twilio_configuration
    end
  end

  def initialize_feature_setting
    create_feature_setting!
  end

  def add_predefined_segments
    Segment.predefined.find_each do |segment|
      shop_segments.create!(segment: segment)
    end
  end
end
