require 'sass'
module Sass::Script::Functions

  include AssetHelpers
  def image_url(file)
    ::Sass::Script::String.new "url('#{image_path(file.value)}')"
  end

end
