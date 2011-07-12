class ColorString

  def initialize(str, color=nil, bg=nil)
    @str, @color, @bg = str, color, bg
  end

  def to_s
    return @str if @color.nil? and @bg.nil?
    s = []
    s << "3#{@color}" unless @color.nil?
    s << "4#{@bg}" unless @bg.nil?
    "\e[#{s.join(';')}m" << @str << "\e[0m"
  end

  def inspect
    "#<ColorString \"#{@str}\", color:#{@color}, bg:#{@bg}>"
  end

  String.public_instance_methods.each do |m|
    unless self.respond_to? m
      define_method(m) do |*arg|
        to_s.send( m, *arg )
      end
    end
  end

  %w(BLACK RED GREEN YELLOW BLUE MAGENTA CYAN WHITE).each_with_index do |color, i|
    const_set(color, i)
    String.class_eval do
      define_method(color.downcase) do 
        ColorString.new(self, i)
      end

      define_method(color.downcase << '_bg') do
        ColorString.new(self, nil, i)
      end
    end

    ColorString.class_eval do
      define_method(color.downcase) do 
        @color = i
        self
      end

      define_method(color.downcase << '_bg') do
        @bg = i
        self
      end
    end

  end
end
