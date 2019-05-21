# use n1
final_message = FinalMessageBuilder.final_sms_message(engagmement.product_abandoned_message,
                                                     code,
                                                     jump_url(code))

# use n2
final_message = FinalMessageBuilder.final_sms_message(engagmement.sms_message,
                                                     code,
                                                     jump_url(code))

# use n3
final_message = FinalMessageBuilder.final_sms_message(engagmement.sms_message,
                                                     code)

# use n4
final_message = FinalMessageBuilder.final_sms_message(engagmement.sms_message,
                                                     engagement.discount_code)

# use n4
replace_from = customer_url_shortener&.short_url
replate_to = customer_url_shortener&.short_url
final_message = MessageUtils.replace_text(engagmement.sms_message, replace_from, replace_to)
final_message = FinalMessageBuilder.final_sms_message(final_message,
                                                     engagement.discount_code)
