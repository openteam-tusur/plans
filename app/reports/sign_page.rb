# encoding: utf-8

class SignPage < Page
  def authors_header
    I18n.t('pluralize.author', :count => work_programm.authors.size)
  end

  def authors
    work_programm.authors
  end

  def subdepartment_chief
    adapt_chief "Зав. обеспечивающей кафедрой", subdepartment
  end

  def department_chief
    adapt_chief "Декан", department
  end

  def coordiantors
    if subspeciality.graduate_subdepartment == subdepartment
      [
        adapt_chief("Зав. профилирующей и выпускающей кафедрой", subdepartment)
      ]
    else
      [
        adapt_chief("Зав. профилирующей кафедрой", subdepartment),
        adapt_chief("Зав. выпускающей кафедрой", subspeciality.graduate_subdepartment)
      ]
    end
  end

  def gos
    if gos = Gos.find_by_speciality_code(speciality.code)
      {
        :title => "#{gos.code} «#{gos.title}»",
        :approved_on => "#{I18n.l(gos.approved_on)} г."
      }
    else
      { :title => '-'*20, :approved_on => '-'*10 }
    end
  end

  private
    def adapt_chief(post, subdivision)
      subdivision.chief(work_programm.year).dup.tap do |chief|
        chief.post = "#{post} #{subdivision.abbr}"
      end
    end
end
