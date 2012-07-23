# encoding: utf-8

class WorkProgrammReport < Prawn::Document
  attr_accessor :work_programm

  delegate :discipline, :to => :work_programm
  delegate :subspeciality, :to => :discipline
  delegate :speciality, :to => :subspeciality
  delegate :subdepartment, :to => :discipline
  delegate :department, :to => :subdepartment
  delegate :loaded_semesters, :to => :discipline
  delegate :year, :to => :speciality, :prefix => true

  def title_page_date_line
    "«____» _____________________ #{work_programm.year} г."
  end

  def title_page_discipline
    "#{discipline.title} (#{discipline.code})"
  end

  def title_page_speciality
    "#{speciality.code} #{speciality.title}"
  end

  def title_page_speciality_kind
    speciality.degree == 'specialty' ? 'Специальность' : 'Направление'
  end

  def title_page_department
    department.title.gsub(/факультет/i, '').squish.sub(/^(.)/) { $1.mb_chars.upcase }
  end

  def title_page_subdepartment
    subdepartment.title.gsub(/кафедра/i, '').squish.sub(/^(.)/) { $1.mb_chars.upcase }
  end

  def title_page_courses
    discipline.loaded_courses.join(', ')
  end

  def title_page_semesters
    loaded_semesters.join(', ')
  end

  def title_page_speciality_year
    "Учебный план набора #{speciality_year.number} года и последующих лет"
  end

  def title_table(field, value, width=120)
    table([[{:content => field, :width => width}, value]], :cell_style => {:border_color => "FFFFFF"})
  end

  def title_page
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
      text "проректор по учебной работе _______________________ Л. А. Боков #{title_page_date_line}", :align => :left, :size => 12
    end
    move_down 16

    text "РАБОЧАЯ ПРОГРАММА", :align => :center, :style => :bold
    move_down 16

    title_table "По дисциплине", title_page_discipline
    title_table title_page_speciality_kind, title_page_speciality
    title_table "Факультет", title_page_department
    title_table "Профилирующая кафедра", title_page_subdepartment, 180
    title_table "Курс", title_page_courses
    title_table "Семестр", title_page_semesters

    move_down 24

    text title_page_speciality_year, :align => :center
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

  def sign_row(post_prefix, subdivision, person)
    [
      { :content => "#{post_prefix}#{subdivision.abbr}\n#{person ? person.science_post : '------'}", :width => 250 },
      { :content => "______________", :width => 120, :align => :center, :valign => :bottom },
      { :content => person ? person.short_name : '-------------', :valign => :bottom, :width => 150 }
    ]
  end

  def sign_page
    gos = Gos.where("speciality = ? OR code = ?", @work_programm.discipline.subspeciality.speciality.title, @work_programm.discipline.subspeciality.speciality.code).order("approved_on desc").first
    gos_info = "Рабочая программа составлена на основании ГОС ВПО для специальности "
    gos_info << (gos ? "#{gos.code} «#{gos.speciality}»" : "----------------------")
    gos_info << ", утвержденного "
    gos_info << (gos ? "#{I18n.l(gos.approved_on)} г." : "----------------------")
    gos_info << ", рассмотрена и утверждена на заседании "
    gos_info << "кафедры «____» ______________ г., протокол № _______"
    text gos_info, :align => :justify, :leading => 5, :indent_paragraphs => 30

    move_down 16
    text I18n.t('pluralize.author', :count => @work_programm.authors.size)

    authors_data = []
    @work_programm.authors.each do |author|
      authors_data << [
        { :content => "#{author.post}\n#{author.science_post}", :width => 250 },
        { :content => "______________", :width => 120, :align => :center, :valign => :bottom },
        { :content => author.short_name, :valign => :bottom, :width => 150 }
      ]
    end

    table(authors_data, :cell_style => {:border_color => "FFFFFF"})

    move_down 16

    table([sign_row("Зав. обеспечивающей кафедрой ",
                    @work_programm.discipline.subdepartment,
                    @work_programm.discipline.subdepartment.chief(@work_programm.year))],
          :cell_style => {:border_color => "FFFFFF"})
    move_down 24

    text "Рабочая программа согласована с факультетом, профилирующей и выпускающей кафедрами специальности", :align => :justify, :leading => 5, :indent_paragraphs => 30

    move_down 16

    sign_data = []
    sign_data << sign_row("Декан ",
                          @work_programm.discipline.subspeciality.subdepartment.department,
                          @work_programm.discipline.subspeciality.subdepartment.department.chief(@work_programm.year))
    if @work_programm.discipline.subspeciality.graduate_subdepartment == @work_programm.discipline.subspeciality.subdepartment
      sign_data << sign_row("Зав. профилирующей и выпускающей кафедрой ",
                            @work_programm.discipline.subspeciality.subdepartment,
                            @work_programm.discipline.subspeciality.subdepartment.chief(@work_programm.year))
    else
      sign_data << sign_row("Зав. профилирующей кафедрой ",
                            @work_programm.discipline.subspeciality.subdepartment,
                            @work_programm.discipline.subspeciality.subdepartment.chief(@work_programm.year))
      sign_data << sign_row("Зав. выпускающей кафедрой ",
                            @work_programm.discipline.subspeciality.graduate_subdepartment,
                            @work_programm.discipline.subspeciality.graduate_subdepartment.chief(@work_programm.year))
    end
    table(sign_data, :cell_style => {:border_color => "FFFFFF"})
  end



  def to_pdf(work_programm)
    self.work_programm = work_programm
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
