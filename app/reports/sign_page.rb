# encoding: utf-8

class SignPage < Page

  delegate :gos, :to => :speciality

  def authors_header
    I18n.t('pluralize.author', :count => work_programm.authors.size)
  end

  def authors
    work_programm.authors
  end

  def subdepartment_chief
    adapt_chief "Зав. обеспечивающей кафедрой", discipline.subdepartment
  end

  def department_chief
    adapt_chief "Декан", department
  end

  def coordiantors
    if graduate_subdepartment == subdepartment
      [
        adapt_chief("Зав. профилирующей и выпускающей кафедрой", subdepartment)
      ]
    else
      [
        adapt_chief("Зав. профилирующей кафедрой", subdepartment),
        adapt_chief("Зав. выпускающей кафедрой", graduate_subdepartment)
      ]
    end
  end

  private
    def adapt_chief(post, subdivision)
      subdivision.chief(work_programm.year).dup.tap do |chief|
        chief.post = "#{post} #{subdivision.abbr}"
      end
    end
end
