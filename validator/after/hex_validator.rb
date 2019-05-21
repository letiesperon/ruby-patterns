# validators/hex_validator.rb
class HexValidator < ActiveModel::EachValidator
  def validate_each(object, attribute, value)
    unless valid_hex?(value)
      object.errors[attribute] << (options[:message] || "must be a valid CSS hex color code")
    end
  end

  private

  def valid_hex?(value)
    value =~ /^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$/i
  end
end
