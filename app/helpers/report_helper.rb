module ReportHelper
  def table(objects, css_class)
    objects = objects.to_a
    if objects.flatten.any?
      table = "<table class=#{css_class}>\n"
      objects.each do |row|
        table << "  <tr>\n"
        row.to_a.each do |cell|
          table << "    <td>#{h cell}</td>\n"
        end
        table << "  </tr>\n"
      end
      table << "</table>\n"
      table.html_safe
    end
  end
end
