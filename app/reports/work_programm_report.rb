# encoding: utf-8

class WorkProgrammReport < Prawn::Document
  attr_accessor :work_programm

  def title_page
    TitlePage.new(work_programm)
  end

  def sign_page
    SignPage.new(work_programm)
  end

  def build_common_title_table(field, value, width=120)
    table([[{:content => field, :width => width}, value]], :cell_style => {:border_color => "FFFFFF", :padding_top => 0} )
  end

  def build_title_page
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

    build_common_title_table "По дисциплине", title_page.discipline_title
    build_common_title_table title_page.speciality_kind, title_page.speciality_title
    build_common_title_table "Факультет", title_page.department_title
    build_common_title_table "Профилирующая кафедра", title_page.subdepartment_title, 180
    build_common_title_table "Курс", title_page.courses
    build_common_title_table "Семестр", title_page.semesters
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

  def build_sign_row(post_prefix, subdivision, person)
    [
      { :content => "#{post_prefix}#{subdivision.abbr}\n#{person.science_post}", :width => 250 },
      { :content => "______________", :width => 120, :align => :center, :valign => :bottom },
      { :content => person.short_name, :valign => :bottom, :width => 150 }
    ]
  end

  def build_sign_table(rows)
    table(rows.map(&:to_a), :cell_style => {:border_color => "FFFFFF"}, :column_widths => [250, 120, 150]) do
      cells.style do |cell|
        case cell.column
        when 1
          cell.align = :center
          cell.valign = :bottom
        when 2
          cell.valign = :bottom
        end
      end
    end
  end

  def build_sign_page
    gos_info = "Рабочая программа составлена на основании ГОС ВПО для специальности #{sign_page.gos[:title]}, "
    gos_info << "утвержденного #{sign_page.gos[:approved_on]}, "
    gos_info << "и утверждена на заседании кафедры «____» ______________ г., протокол № _______"
    text gos_info, :align => :justify, :leading => 5, :indent_paragraphs => 30

    move_down 16
    text sign_page.authors_header

    build_sign_table(sign_page.authors)

    move_down 16

    build_sign_table([sign_page.subdepartment_chief])
    move_down 24

    text "Рабочая программа согласована с факультетом, профилирующей и выпускающей кафедрами специальности",
          :align => :justify,
          :leading => 5,
          :indent_paragraphs => 30

    move_down 16

    build_sign_table([sign_page.department_chief])
    build_sign_table(sign_page.coordiantors)
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

    build_title_page

    start_new_page
    build_sign_page

    render
  end
end
