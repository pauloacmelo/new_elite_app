class CardProcessingUploader < CarrierWave::Uploader::Base

  include CarrierWave::MiniMagick
  storage :file

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def extension_white_list
    %w(tif rar zip)
  end

  # def filename
  #   "original.#{model.file.file.extension}" if original_filename 
  # end
end
