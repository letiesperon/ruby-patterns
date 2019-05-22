class MessagingService
  attr_reader :error

  def text_phone(phone, message_body)
    # invoke Twilio API
  rescue => ex
    @error = ex.message
  end
end

service = MessagingService.new
service.text_phone('+111111111', 'Hello!')
log(error) if service.error
