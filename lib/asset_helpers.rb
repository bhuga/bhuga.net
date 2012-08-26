module AssetHelpers
  def digest_asset_path(pathname)
    '/assets/' + settings.sprockets.find_asset(pathname).digest_path
  end

  def asset_host
    ENV['ASSET_HOST'].nil? ? '' : "http://#{ENV['ASSET_HOST']}"
  end

  def asset_path(asset)
    "#{asset_host}#{digest_asset_path(asset)}"
  end

  def image_path(image)
    "#{asset_host}/images/#{image}"
  end
end
