class OutboundCampaignForm
  include ActiveModel::Model

  attr_reader :setting, :sms_engagement, :web_push_engagement,
              :sms_engagement_image_data, :web_push_engagement_image_data
  attr_accessor :shop, :campaign, :campaign_type, :enabled, :name, :status,
                :engagements

  validate :validate_form

  def save
    build_models

    return false if invalid?

    ActiveRecord::Base.transaction do
      campaign.save!
      setting.save!
      sms_engagement&.save!
      web_push_engagement&.save!
    end

    invoke_attachment_handler(sms_engagement, sms_engagement_image_data)
    invoke_attachment_handler(web_push_engagement, web_push_engagement_image_data)

    true
  end

  private

  def build_models
    @campaign = campaign || shop.campaigns.new
    @campaign.attributes = campaign_attributes

    @setting = campaign.outbound_setting || campaign.build_outbound_setting
    @setting.attributes = setting_attributes

    engagements.each do |engagement|
      case engagement[:type]
      when 'sms'
        @sms_engagement = setting.sms_engagement || setting.build_sms_engagement
        sms_engagement.attributes = sms_attributes(engagement)
        @sms_engagement_image_data = engagement[:image_data]
      when 'web_push'
        @web_push_engagement = setting.web_push_engagement || setting.build_web_push_engagement
        web_push_engagement.attributes = web_push_attributes(engagement)
        @web_push_engagement_image_data = engagement[:image_data]
      end
    end
  end

  def campaign_attributes
    {
      new_campaign_type: :outbound,
      campaign_type: :outbound,
      enabled: enabled,
      name: name
    }
  end

  def setting_attributes
    {
      status: status
    }
  end

  def sms_attributes(engagement)
    engagement.slice(:enabled, :segment_id, :discount_percentage,
                     :discount_code, :discount_expires_in, :message,
                     :append_legal_text_to_sms, :delivery_mode,
                     :delivery_date_time, :applied_discount_code_to_url_shortener)
  end

  def web_push_attributes(engagement)
    engagement.slice(:enabled, :popup_title, :popup_body,
                     :link, :discount_code, :delivery_mode,
                     :delivery_date_time)
  end

  def invoke_attachment_handler(engagement, image_data)
    return unless engagement

    AttachmentHandlerService.new(
      engagement.image,
      attachment_data: image_data
    ).handle
  end

  def validate_form
    promote_errors(:campaign, campaign.errors) if campaign.invalid?
    promote_errors(:setting, setting.errors) if setting.invalid?
    promote_errors(:sms_engagement, sms_engagement.errors) if sms_engagement&.invalid?
    promote_errors(:web_push_engagement, web_push_engagement.errors) if web_push_engagement&.invalid?
  end

  def promote_errors(namespace, child_errors)
    child_errors.each do |attribute, message|
      errors.add("#{namespace}.#{attribute}", message)
    end
  end
end
