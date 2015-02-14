class Book
  attr_accessor :title

  def initialize(params = {})
    params.each do |attr, value|
      public_send("#{attr}=", value)
    end
  end

  def to_s
    "<span>#{title}</span>".html_safe
  end
end
