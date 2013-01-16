class StudentExamCardUploader < CarrierWave::Uploader::Base

  include CarrierWave::MiniMagick
  storage :file

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def extension_white_list
    %w(tif)
  end

  def filename 
    "original.tif" if original_filename
  end 

  version :normalized_tif do
    process :normalize

    def full_filename(for_file = model.logo.file) 
      "normalized.tif" 
    end 
  end

  version :normalized_png do
    process :normalize
    process convert: 'png'

    def full_filename(for_file = model.logo.file) 
      "normalized.png" 
    end 
  end

  def normalize
    # TODO
  end
end