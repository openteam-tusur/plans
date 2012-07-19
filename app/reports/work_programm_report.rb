# encoding: utf-8

class WorkProgrammReport < Prawn::Document

  def title_page
    move_down 20
    text "МИНИСТЕРСТВО ОБРАЗОВАНИЯ И НАУКИ РОСИИЙСКОЙ ФЕДЕРАЦИИ", :align => :center, :size => 11, :style => :bold
    move_down 4
    text "Федеральной государственное бюджетное образовательное учереждение высшего профессионального образования", :align => :center, :size => 11
    move_down 4
    text "«ТОМСКИЙ ГОСУДАРСТВЕННЫЙ УНИВЕРСИТЕТ СИСТЕМ УПРАВЛЕНИЯ И РАДИОЭЛЕКТРОНИКИ» (ТУСУР)", :align => :center, :size => 12, :style => :bold
    move_down 8

    bounding_box([300, 600], :width => 220, :height => 90) do
      text "УТВЕРЖДАЮ", :align => :center, :size => 10
      move_down 4
      text "Первый проректор-", :align => :left, :size => 10
      move_down 4
      text "проректор по учебной работе _________________________ Л. А. Боков «____» _______________________ #{@work_programm.year} г.", :align => :left
    end

    text "РАБОЧАЯ ПРОГРАММА", :align => :center, :style => :bold
    loaded_semesters = @work_programm.discipline.loaded_semesters
    bounding_box([0,480], :width => 400, :height => 130) do
      text "По дисциплине #{@work_programm.discipline.title}"
      move_down 8
      text "Для специальности #{@work_programm.discipline.subspeciality.speciality.code} #{@work_programm.discipline.subspeciality.speciality.title}"
      move_down 8
      text "Факультет #{@work_programm.discipline.subspeciality.subdepartment.department.title.gsub(/[ф|Ф]акультет/, '')}"
      move_down 8
      text "Профилирующая кафедра #{@work_programm.discipline.subspeciality.subdepartment.title}"
      move_down 8
      text "Курс #{@work_programm.discipline.loaded_courses.join(', ')}"
      move_down 8
      text "Семестр #{loaded_semesters.join(', ')}"
    end

    text "Учебный план набора #{@work_programm.discipline.subspeciality.speciality.year.number} года и последующих лет", :align => :center
    move_down 8

    text "Распределение учебного времени", :align => :left
    move_down 8

    grouped_loading = @work_programm.discipline.loadings.group_by(&:loading_kind)

    loading_data_header = ["", "Всего часов"]
    loading_data_header += loaded_semesters.map { |number| "#{number} семестр" } if loaded_semesters.size > 1
    loading_data = [ loading_data_header ]

    Loading.classroom_kinds.each do |loading_kind|
      next unless kind_loadings = grouped_loading[loading_kind]
      loading_data_str = [ Loading.human_enum_values(:loading_kind)[loading_kind], kind_loadings.sum(&:value) ]
      loaded_semesters.each do |semester_number|
        loading_data_str << kind_loadings.select {|loading| loading.semester.number == semester_number }.sum(&:value)
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

    table(loading_data, :cell_style => {:border_color => "CCCCCC"})

    move_down 8

    @work_programm.discipline.checks.group_by(&:report_kind_value).each do |check_kind, checks|
      text "#{check_kind} #{checks.map(&:semester).map(&:number).join(', ')} семестр"
    end

    bounding_box([250,20], :width => 50, :height => 50) do
      text "#{@work_programm.year}", :align => :center
    end
  end

  def sign_page
    text ""
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
    font "Times", :size => 12

    title_page
    start_new_page
    sign_page

    render
  end
end
