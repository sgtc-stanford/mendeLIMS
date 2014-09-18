# encoding: utf-8
require 'carrierwave/processing/mime_types'

class AttachmentUploader < CarrierWave::Uploader::Base
  FILES_ROOT = (SITE_URL.include?('stanford.edu') ? File.join(Rails.root, "..", "..", "shared", "attached_files") :
                                                    File.join(Rails.root, "..", "LIMSFiles", "AttachedFile"))

  include CarrierWave::MimeTypes
  process :set_content_type

  # Include RMagick or MiniMagick support:
  # include CarrierWave::RMagick
  # include CarrierWave::MiniMagick

  # Choose what kind of storage to use for this uploader:
  storage :file
  # storage :fog

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    #"#{FILES_ROOT}/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
    "#{FILES_ROOT}/#{model.sampleproc_type}"
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  # def default_url
  #   # For Rails 3.1+ asset pipeline compatibility:
  #   # ActionController::Base.helpers.asset_path("fallback/" + [version_name, "default.png"].compact.join('_'))
  #
  #   "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  # end

  # Process files as they are uploaded:
  # process :scale => [200, 300]
  #
  # def scale(width, height)
  #   # do something
  # end

  # Create different versions of your uploaded files:
  # version :thumb do
  #   process :scale => [50, 50]
  # end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  def extension_white_list
    %w(jpg jpeg gif png xls xlsx doc docx txt csv)
  end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  def filename
    "#{model.sampleproc_id}_#{original_filename}" if original_filename
  end

end
