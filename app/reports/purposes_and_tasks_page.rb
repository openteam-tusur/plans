# encoding: utf-8

class PurposesAndTasksPage < Page
  def to_html
    <<-HTML
      <meta http-equiv="content-type" content="text/html; charset=utf-8" />
      <style>h1 {font-size:14px;}</style>
      <h1>1. Цели и задачи дисциплины, ее место в учебном процессе</h1>
      <h2>1.1 Цели преподавания дисциплины</h2>
      #{work_programm.purpose_html}
      <h2>1.2 Задачи изучения дисциплины</h2>
      #{work_programm.task_html}
      <h2>1.3 Место дисциплины в структуре ООП</h2>
      #{dependencies}
    HTML
  end

  def to_pdf(filename)
    File.open(filename, 'wb') do |file|
      file << WickedPdf.new.pdf_from_string(to_html)
    end
  end

  def dependencies
    <<-HTML
      <p>
        Дисциплина «#{discipline.title}» входит в #{discipline.decoded_component} компонент цикла «#{discipline.cycle}» по направлению «#{speciality.gos.title}».
        #{previous_disciplines}
        #{current_disciplines}
        #{subsequent_disciplines}
      </p>
    HTML
  end

  %w[previous_disciplines current_disciplines subsequent_disciplines].each do |type|
    define_method type do
      I18n.t "pluralize.work_programm.#{type}",
            :count => work_programm.send(type).count,
            :disciplines => work_programm.send(type).map{|d| "«#{d.title}»"}.join(', ')
    end
  end


end
