# encoding: utf-8

class WorkProgrammReport < Prawn::Document
  attr_accessor :work_programm

  def render_common_title_table(field, value, width=120)
    table([[{:content => field, :width => width}, value]], :cell_style => {:border_color => "FFFFFF", :padding_top => 0} )
  end

  def title_page
    TitlePage.new(work_programm)
  end

  def render_title_page
    text "МИНИСТЕРСТВО ОБРАЗОВАНИЯ И НАУКИ РОСИИЙСКОЙ ФЕДЕРАЦИИ", :align => :center, :size => 13, :style => :bold
    move_down 4

    text "Федеральной государственное бюджетное образовательное учереждение высшего профессионального образования", :align => :center, :size => 14
    move_down 4

    text "«ТОМСКИЙ ГОСУДАРСТВЕННЫЙ УНИВЕРСИТЕТ СИСТЕМ УПРАВЛЕНИЯ И РАДИОЭЛЕКТРОНИКИ» (ТУСУР)", :align => :center, :size => 15, :style => :bold
    move_down 4

    bounding_box([300, 685], :width => 220, :height => 100) do
      text "УТВЕРЖДАЮ", :align => :center, :size => 12
      move_down 4
      text "Первый проректор-", :align => :left, :size => 12
      move_down 4
      text "проректор по учебной работе _______________________ Л. А. Боков #{title_page.date_line}", :align => :left, :size => 12
    end

    text "РАБОЧАЯ ПРОГРАММА", :align => :center, :style => :bold
    move_down 16

    render_common_title_table "По дисциплине", title_page.discipline_title
    render_common_title_table title_page.speciality_kind, title_page.speciality_title
    render_common_title_table "Факультет", title_page.department_title
    render_common_title_table "Профилирующая кафедра", title_page.subdepartment_title, 180
    render_common_title_table "Курс", title_page.courses
    render_common_title_table "Семестр", title_page.semesters
    move_down 24

    text title_page.speciality_year, :align => :center
    move_down 24

    text "Распределение учебного времени", :align => :left
    move_down 8

    table(title_page.scheduling.to_a, :cell_style => {:border_color => "000000"})
    move_down 16

    table(title_page.checks.to_a, :cell_style => { :border_color => 'ffffff', :padding_top => 0})

    text title_page.year_line, :align => :center, :valign => :bottom
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

    render_title_page
    start_new_page
    sign_page

    render
  end
end
