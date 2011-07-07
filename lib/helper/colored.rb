class String

  def red;  color 1;  end
  def green; color 2; end
  def yellow; color 3; end
  def blue; color 4; end
  def purple; color 5; end

  def red_bg; bg 1; end
  def green_bg; bg 2; end
  def yellow_bg; bg 3; end
  def blue_bg; bg 4; end
  def purple_bg; bg 5; end

  def color( fore, bg=nil )
    return self.to_s if fore.nil? and bg.nil?
    s = []
    s << "3#{fore}" unless fore.nil?
    s << "4#{bg}" unless bg.nil?
    "\e[#{s.join(';')}m" << self << "\e[0m"
  end

  def bg( color )
    color( nil, color)
  end

end
