class UploadImageValidator < ActiveModel::EachValidator

  def validate_each(record, attribute, value)
    if value
      begin
        image = Magick::Image.read(value.path).first
        record.errors.add(attribute, :invalid_format) unless ['JPEG', 'PNG'].include?(image.format)
        record.errors.add(attribute, :image_is_big) if image.filesize > (10 * 1024 * 1024)
      rescue Magick::ImageMagickError => e
        record.errors.add(attribute, e.message)
      end
    else
      record.errors.add(attribute, :empty)
    end
  end
end