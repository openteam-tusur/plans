# encoding: utf-8

class WorkProgrammReport < Prawn::Document

  def title_page
    #move_down 20
    text "МИНИСТЕРСТВО ОБРАЗОВАНИЯ И НАУКИ РОСИИЙСКОЙ ФЕДЕРАЦИИ", :align => :center, :size => 13, :style => :bold
    move_down 4
    text "Федеральной государственное бюджетное образовательное учереждение высшего профессионального образования", :align => :center, :size => 14
    move_down 4
    text "«ТОМСКИЙ ГОСУДАРСТВЕННЫЙ УНИВЕРСИТЕТ СИСТЕМ УПРАВЛЕНИЯ И РАДИОЭЛЕКТРОНИКИ» (ТУСУР)", :align => :center, :size => 15, :style => :bold
    move_down 8

    bounding_box([300, 650], :width => 220, :height => 90) do
      text "УТВЕРЖДАЮ", :align => :center, :size => 12
      move_down 4
      text "Первый проректор-", :align => :left, :size => 12
      move_down 4
      text "проректор по учебной работе _______________________ Л. А. Боков «____» _____________________ #{@work_programm.year} г.", :align => :left, :size => 12
    end
    move_down 16

    text "РАБОЧАЯ ПРОГРАММА", :align => :center, :style => :bold
    move_down 16
    loaded_semesters = @work_programm.discipline.loaded_semesters

    discipline_title_cell = make_cell(:content => "По дисциплине", :width => 120)
    discipline_title_table = [[discipline_title_cell, "#{@work_programm.discipline.title} (#{@work_programm.discipline.code})"]]
    table(discipline_title_table, :cell_style => {:border_color => "FFFFFF"})

    discipline_speciality_cell = make_cell(:content => "Специальность", :width => 120)
    discipline_speciality_table = [[discipline_speciality_cell, "#{@work_programm.discipline.subspeciality.speciality.code} #{@work_programm.discipline.subspeciality.speciality.title}"]]
    table(discipline_speciality_table, :cell_style => {:border_color => "FFFFFF"})

    discipline_department_table = [["Факультет #{@work_programm.discipline.subspeciality.subdepartment.department.title.gsub(/[ф|Ф]акультет/, '')}"]]
    table(discipline_department_table, :cell_style => {:border_color => "FFFFFF"})

    discipline_subdepartment_cell = make_cell(:content => "Профилирующая кафедра", :width => 180)
    discipline_subdepartment_table = [[discipline_subdepartment_cell, "#{@work_programm.discipline.subspeciality.subdepartment.title}"]]
    table(discipline_subdepartment_table, :cell_style => {:border_color => "FFFFFF"})

    discipline_courses_cell = make_cell(:content => "Курс", :width => 120)
    discipline_courses_table = [[discipline_courses_cell,"#{@work_programm.discipline.loaded_courses.join(', ')}"]]
    table(discipline_courses_table, :cell_style => {:border_color => "FFFFFF"})

    discipline_semesters_cell = make_cell(:content => "Семестр", :width => 120)
    discipline_semesters_table = [[discipline_semesters_cell, "#{loaded_semesters.join(', ')}"]]
    table(discipline_semesters_table, :cell_style => {:border_color => "FFFFFF"})
    move_down 24

    text "Учебный план набора #{@work_programm.discipline.subspeciality.speciality.year.number} года и последующих лет", :align => :center
    move_down 24

    text "Распределение учебного времени", :align => :left
    move_down 8

    grouped_loading = @work_programm.discipline.loadings.group_by(&:loading_kind)

    loading_data_header = loaded_semesters.size > 1 ? [{:content => "", :rowspan=> 2}, {:content => "Всего часов", :rowspan => 2}, {:content => "По семестрам", :colspan => loaded_semesters.size}] : ["", "Всего часов"]

    loading_data = [ loading_data_header ]
    loading_data << loaded_semesters.map { |number| "#{number}" } if loaded_semesters.size > 1

    Loading.classroom_kinds.each do |loading_kind|
      next unless kind_loadings = grouped_loading[loading_kind]
      loading_data_str = [ Loading.human_enum_values(:loading_kind)[loading_kind], kind_loadings.sum(&:value) ]
      loaded_semesters.each do |semester_number|
        summ_value = kind_loadings.select {|loading| loading.semester.number == semester_number }.sum(&:value)
        loading_data_str << (summ_value > 0 ? summ_value : "-")
      end if loaded_semesters.size > 1
      loading_data << loading_data_str
    end

    loading_data_classroom_summ_str = [ 'Всего аудиторных занятий', @work_programm.discipline.calculated_classroom_loading_summ ]
    loading_data_classroom_summ_str += loaded_semesters.map { |number| @work_programm.discipline.calculated_classroom_loading_summ_for_semester(number) } if loaded_semesters.size > 1
    loading_data << loading_data_classroom_summ_str


    Loading.srs_kinds.each do |loading_kind|
      next unless kind_loadings = grouped_loading[loading_kind]
      next if loading_kind == 'exam' && @work_programm.discipline.calculated_loading_summ > @work_programm.discipline.summ_loading
      loading_data_str = [ Loading.human_enum_values(:loading_kind)[loading_kind], kind_loadings.sum(&:value) ]
      loaded_semesters.each do |semester_number|
        loading_data_str << kind_loadings.select {|loading| loading.semester.number == semester_number }.sum(&:value)
      end if loaded_semesters.size > 1
      loading_data << loading_data_str
    end

    loading_data_footer = [ 'Общая трудоемкость', @work_programm.discipline.summ_loading ]
    loading_data_footer += loaded_semesters.map { |number| @work_programm.discipline.calculated_loading_summ_for_semester(number) } if loaded_semesters.size > 1
    loading_data << loading_data_footer

    table(loading_data, :cell_style => {:border_color => "000000"})

    move_down 16

    @work_programm.discipline.checks.group_by(&:report_kind_value).each do |check_kind, checks|
      text "#{check_kind} #{checks.map(&:semester).map(&:number).join(', ')} семестр"
    end

    text "#{@work_programm.year}", :align => :center, :valign => :bottom
  end

  def sign_page
    text "Рабочая программа составлена на основании ГОС ВПО для специальности"
    move_down 8
    text "___________________________________________________________"
    move_down 8
    text "утвержденного _________________________, рассмотрена и утверждена на заседании"
    move_down 8
    text "кафедры «____» ______________ г., протокол № _______"
    move_down 20


    sign_creator_data = [["Разработчик", "", ""],
                 ["________________________________", "_________________", "_____________________"],
                 ["Зав. обеспечивающей кафедрой _________", "_________________", "_____________________"]]

    table(sign_creator_data, :cell_style => {:border_color => "CCCCCC"})

    move_down 16

    text "Рабочая программа согласована с факультетом, профилирующей и выпускающей кафедрами специальности"

    move_down 16

    sign_data = [["Декан __________", "________________", "________________"],
                ["Зав. профилирующей кафедрой ___________", "_______________", "______________"],
                ["Зав. выпускающей кафедрой ___________", "_______________", "_______________"]]
    table(sign_data, :cell_style => {:border_color => "CCCCCC"})
  end

  def to_pdf(work_programm)
    @work_programm = work_programm
    if RUBY_PLATFORM =~ /freebsd/
      font_families.update(
        "Times" => {
        :bold   => "/usr/local/lib/X11/fonts/webfonts/timesb.ttf",
        :italic => "/usr/local/lib/X11/fonts/webfonts/timesi.ttf",
        :normal => "/usr/local/lib/X11/fonts/webfonts/times.ttf" })
    else
      font_families.update(
        "Times" => {
        :bold   => "/usr/share/fonts/truetype/msttcorefonts/Times_New_Roman_Bold.ttf",
        :italic => "/usr/share/fonts/truetype/msttcorefonts/Times_New_Roman_Italic.ttf",
        :normal => "/usr/share/fonts/truetype/msttcorefonts/Times_New_Roman.ttf" })
    end
    font "Times", :size => 14

    title_page
    start_new_page
    sign_page

    render
  end
end
