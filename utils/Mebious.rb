require 'rack'
require 'digest'

# coding: utf-8
module Mebious
  def gencolor(hue)
    sat = rand(100)
    lum = rand(20...100)
    
    return "hsl(#{hue}, #{sat}%, #{lum}%)"
  end
  
  def green
    self.gencolor(120)
  end

  def red
    self.gencolor(0)
  end

  def fonts
    fonts = [
      "Times New Roman, Times, serif",
      "Arial, Helvetica, sans-serif",
      "Georgia, Times New Roman, Times, serif",
      "Courier New, Courier, monospace"
    ]

    fonts.shuffle.first
  end
  
  def stylize(post)
    if post['is_admin'] == 1
      color = self.red
    else
      color = self.green
    end

    size = rand(0.8...2.0).round(2)
    x = rand(0.1...40).round(2)
    font = self.fonts
    
    return "color: #{color}; " \
           "font-family: #{font};" \
           "font-size: #{size}em; " \
           "position: relative; " \
           "left: #{x}%;"
           
  end

  def corrupt(str)
    corruptions = [
      {"u" => "ü"},
      {"e" => "è"},
      {"e" => "ë"},
      {"a" => "@"},
      {"u" => "ù"},
      {"a" => "à"},
      {"o" => "ò"},
      {"s" => "$"},
      {"i" => "ï"},
      {"y" => "ÿ"},
      {"i" => "î"},
      {"a" => "á"},
      {"a" => "ã"},
      {"e" => "ê"},
      {"i" => "ï"},
      {"o" => "ô"},
      {"o" => "ø"},
      {"i" => "1"}
    ]
    
    if rand(2) == 1
      n = rand(1..2)
      chosen = corruptions.shuffle[0...n]
      chosen.each { |corruption|
        corruption.each_pair { |k, v|
          str = str.gsub(k, v)
        }
      }
      
      return str
    else
      return str
    end    
  end
  
  def sanitize(str)
    Rack::Utils.escape_html str
  end

  def digest(str)
    Digest::SHA1.hexdigest str
  end

  module_function :green, :red, :gencolor, :stylize, :fonts, :corrupt, :sanitize, :digest
end
