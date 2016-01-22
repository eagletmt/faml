# frozen_string_literal: true
class Book
  include ActiveModel::Model

  attr_accessor :id, :title

  def to_s
    "<span>#{title}</span>".html_safe
  end
end
