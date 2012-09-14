# encoding: utf-8

class SignPage < Page

  delegate :gos, :to => :speciality

  def protocol_date
    I18n.l(work_programm.protocol.signed_on, :format => "%d %B %Y г.")
  end

  def protocol_number
    work_programm.protocol.number
  end

  def authors_header
    I18n.t('pluralize.author', :count => work_programm.authors.size)
  end

  def authors
    work_programm.authors
  end

  def subdepartment_chief
    adapt_chief "Зав. обеспечивающей кафедрой", provided_subdepartment
  end

  def department_chief
    adapt_chief "Декан", department
  end

  def coordiantors
    if profiled_subdepartment == graduated_subdepartment
      [
        adapt_chief("Зав. профилирующей и выпускающей кафедрой", profiled_subdepartment)
      ]
    else
      [
        adapt_chief("Зав. профилирующей кафедрой", profiled_subdepartment),
        adapt_chief("Зав. выпускающей кафедрой", graduated_subdepartment)
      ]
    end
  end

  private
    def adapt_chief(post, subdepartment)
      subdepartment.chief(work_programm.year).dup.tap do |chief|
        chief.post = "#{post} #{subdepartment.abbr}"
      end
    end
end
