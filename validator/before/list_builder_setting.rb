# models/list_builder_setting.rb
class ListBuilderSetting < ApplicationRecord
  # ...
  HEG_REGEX = /^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$/i

  validates :text_color, :background_color, presence: true
  validate :valid_text_color, :valid_background_color
  # ...

  private

  def valid_text_color
    unless text_color =~ HEG_REGEX
      self.errors[:text_color] << 'must be a valid CSS hex color code'
    end
  end

  def valid_background_color
    unless background_color =~ HEG_REGEX
      self.errors[:background_color] << 'must be a valid CSS hex color code'
    end
  end
end
