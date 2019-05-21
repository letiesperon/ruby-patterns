module FinalMessageBuilder
  extend self

  def final_sms_message(sms_message, custom_code, jump_url = nil)
    message = MessageUtils.replace_code(message, custom_code)
    message = MessageUtils.append_jump_url(message, jump_url) if jump_url
    message = MessageUtils.append_legal_text(message) if append_legal_text_to_sms
    message
  end
end
