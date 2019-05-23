module Api
  module V1
    class CampaignsController < Api::V1::ApiController
      helper_method :campaign
      before_action :validate_date_params, only: :metrics
      before_action :validate_campaign_editable, only: :update

      def create
        if params['campaign_type'] == 'outbound'
          upsert_outbound_campaign(shop: current_shop)
        else
          @campaign = current_shop.campaigns.create!(campaign_params)
        end
      end

      def customers
        @customers = campaign
                     .engaged_customers
                     .search_results(params[:search])
                     .order('last_engaged_at DESC')
                     .includes(:campaign)
                     .page(params[:page])

        @after_page_count = PaginationService.new(@customers).after_page_count
      end

      def metrics
        service = CampaignMetricsService.new(campaign, params[:date_from], params[:date_to])
        @metrics = service.metrics
      end

      def update
        if campaign.outbound?
          upsert_outbound_campaign(campaign: campaign)
        else
          campaign.update!(campaign_params)
        end
      end

      def index
        @campaigns = current_shop.campaigns
                                 .with_settings
                                 .with_engagements
                                 .order(id: :desc)
      end

      def show; end

      def url_shortener
        campaign.update!(campaign_params) if campaign.outbound? && params[:campaign].present?

        @url_shortener = UrlShortenerService.new(campaign, url_shortener_params)
                                            .create_url_shortener
      end

      private

      def upsert_outbound_campaign(options = {})
        form = OutboundCampaignForm.new(params.merge(options))
        if form.save
          @campaign = form.campaign
        else
          raise ActiveRecord::RecordInvalid.new, form.errors.messages
        end
      end

      def validate_date_params
        date_from = params[:date_from]
        date_to = params[:date_to]

        return true unless date_from && date_to

        Date.parse(date_from) && Date.parse(date_to)
      rescue ArgumentError
        render_bad_request('Wrong time interval')
      end

      def validate_campaign_editable
        return true if campaign.can_be_edited?

        render_bad_request('It is not possible to edit the campaign right now')
      end

      def campaign_params
        params.require(:campaign)
              .permit(
                :new_campaign_type,
                :campaign_type,
                :enabled,
                :name,
                abandoned_cart_setting_attributes: abandoned_cart_setting_attributes,
                list_builder_setting_attributes: list_builder_setting_attributes,
                form_setting_attributes: form_setting_attributes,
                text_in_setting_attributes: text_in_setting_attributes,
                automation_setting_attributes: automation_setting_attributes
              )
      end

      def abandoned_cart_setting_attributes
        [:channel_id,
         engagements_attributes:
           %i[id deleted discount_percentage discount_code
              discount_expires_in time_til_engagement
              channel_id append_legal_text_to_sms message product_abandoned_message],
         web_push_engagements_attributes:
           %i[id deleted discount_percentage discount_code
              discount_expires_in time_til_engagement
              popup_title popup_body]]
      end

      def list_builder_setting_attributes
        %i[id delay page_displays display_on
           submit_confirmation_message sms_message
           call_to_action_desktop privacy_policy_url
           text_color background_color
           discount_code append_legal_text_to_sms
           mobile_background_opacity desktop_enabled mobile_enabled
           call_to_action_android call_to_action_ios]
      end

      def form_setting_attributes
        %i[title description sms_checkbox_label button_label
           discount_code submit_confirmation_message sms_message
           sms_message_enabled fine_print
           show_first_name show_last_name show_phone_number
           show_email append_legal_text_to_sms]
      end

      def text_in_setting_attributes
        %i[keyword sms_message append_legal_text_to_sms discount_code]
      end

      def automation_setting_attributes
        [:trigger_type, :trigger_action,
         engagements_attributes:
           %i[id deleted time_til_engagement
              sms_enabled web_push_enabled messenger_enabled
              sms_message messenger_body web_push_title web_push_body
              discount_code discount_percentage discount_expires_in]]
      end

      def campaign
        @campaign ||= current_shop.campaigns.find(campaign_id)
      end

      def campaign_id
        params[:campaign_id] || params[:id]
      end

      def url_shortener_params
        params.permit(:base_url, :utm_source, :utm_medium, :utm_campaign)
      end
    end
  end
end
