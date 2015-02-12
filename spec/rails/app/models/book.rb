class Book
  include ActiveModel::Model

  attr_accessor :title

  def to_s
    "<span>#{title}</span>".html_safe
  end
end
