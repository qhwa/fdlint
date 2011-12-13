class ColorString

  @@colors = %w(black red green yellow blue magenta cyan white)

  def self.colors
    @@colors
  end

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
      define_method(m) { |*arg| to_s.send( m, *arg ) }
    end
  end

  @@colors.each_with_index do |color, i|
    String.class_eval do
      define_method(color) { ColorString.new(self, i) }
      define_method(color << '_bg') { ColorString.new(self, nil, i) }
    end

    ColorString.class_eval do
      define_method(color) { @color = i; self }
      define_method(color << '_bg') { @bg = i; self }
    end

  end
end

