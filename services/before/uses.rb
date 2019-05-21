# use n1
final_message = engagement.final_sms_message(custom_code: code,
                                            jump_url: jump_url(code),
                                            message_field: :product_abandoned_message)


# use n2
final_message = engagement.final_sms_message(custom_code: code,
                                            jump_url: jump_url(code),
                                            message_field: :sms_message)

# use n3
final_message = engagement.final_sms_message(custom_code: code)

# use n4
final_message = setting.final_sms_message

# use n5
final_message = campaign.setting.final_sms_message(
  replace_from: url_shortener&.short_url,
  replace_to: customer_url_shortener&.short_url
)
