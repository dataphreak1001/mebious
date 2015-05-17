module TextWarper
  def gen_hsl_green
    # thanks to CSS' hsl() this is trivial
    hue = 120
    sat = rand(100)
    lum = rand(100)
    return "hsl(#{hue}, #{sat}%, #{lum}%)"
  end

  def warpchars(str)
    
  end

  module_function :gen_hsl_green
end
