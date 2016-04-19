require "mime/types"
require "mini_magick"

class Image < ActiveRecord::Base
  def self.add(tmpfile, ip)
    stamp = Time.now.to_i
    url   = self.filename
    checksum  = Digest::MD5.file(tmpfile).to_s
    extension = get_ext tmpfile

    if !valid?(tmpfile) or extension.empty?
      return false
    end

    if duplicate? checksum
      return false
    end

    if !process(tmpfile.path, "public/images/#{url << extension}")
      return false
    end

    self.create({
      :spawn => stamp,
      :url   => url,
      :ip => ip,
      :checksum => checksum
    })

    return true
  end

  def self.process(input, output)
    begin
      MiniMagick::Tool::Convert.new { |convert|
        convert << input
        convert.resize "30625@"
        convert.colorspace "gray"
        convert.fill "rgb(0, 255, 0)"
        convert.tint "80%"
        convert.dither "FloydSteinberg"
        convert.colors 3
        convert.brightness_contrast "-50"
        convert << output
      }

      return true
    rescue MiniMagick::Error => e
      return false
    end
  end

  def self.get_ext(tmpfile)
    mimes = MIME::Types.type_for tmpfile.path
    if mimes.empty?
      return ""
    else
      case mimes.first.content_type
      when "image/png"
        return ".png"
      when "image/jpeg"
        return ".jpg"
      when "image/jpg"
        return ".jpg"
      else
        return ""
      end
    end
  end

  def self.duplicate?(checksum)
    if self.last.nil?
      return false
    else
      return (self.last.checksum.to_s == checksum)
    end
  end

  def self.valid?(tmpfile)
    mimes = MIME::Types.type_for tmpfile.path
    if mimes.empty?
      return false
    else
      case mimes.first.content_type
      when "image/png", "image/jpeg", "image/jpg"
        true
      else
        false
      end
    end
  end

  def self.filename
    SecureRandom.urlsafe_base64(11)
  end
end
