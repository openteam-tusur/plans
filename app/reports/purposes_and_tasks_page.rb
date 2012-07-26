# encoding: utf-8

class PurposesAndTasksPage < Page
  def purposes
    work_programm.purpose_html
  end

  def tasks
    work_programm.task_html
  end

  def dependencies
    <<-HTML.html_safe
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