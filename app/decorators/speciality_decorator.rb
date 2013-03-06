# encoding: utf-8

class SpecialityDecorator < Draper::Decorator
  delegate :code, :title, :year, :gos2?

  def gos
    gos2? ? "ГОС-2" : "ФГОС-3"
  end

  def full_title
    "#{code} — #{title}"
  end

  def degree
    model.degree.text
  end
end
