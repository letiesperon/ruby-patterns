# app/models/concerns/discountable.rb
module Discountable
  extend ActiveSupport::Concern

  def final_sms_message(jump_url: nil, custom_code: nil, replace_from: nil, replace_to: nil,
                        message_field: :sms_message)
    message = replaced_code_on_message(custom_code: custom_code, message_field: message_field)
    message = MessageUtils.append_jump_url(message, jump_url) if jump_url
    message = MessageUtils.append_legal_text(message)
    message = MessageUtils.replace_text(message, replace_from, replace_to)
    message
  end

  def replaced_code_on_message(custom_code: nil, message_field: :sms_message)
    message = public_send(message_field) || public_send(:sms_message)
    MessageUtils.replace_code(message, custom_code || discount_code)
  end

  def final_popup_title(custom_code = nil)
    MessageUtils.replace_code(popup_title, custom_code || discount_code)
  end

  def final_popup_body(custom_code = nil)
    MessageUtils.replace_code(popup_body, custom_code || discount_code)
  end
end
