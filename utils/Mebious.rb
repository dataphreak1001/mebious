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

    size = rand(0.8...2.5).round(2)
    x = rand(0.1...40).round(2)
    font = self.fonts
    
    return "color: #{color}; " \
           "font-family: #{font};" \
           "font-size: #{size}em; " \
           "position: relative; " \
           "left: #{x}%;"
           
  end
  
  module_function :green, :red, :gencolor, :stylize, :fonts
end
