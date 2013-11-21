class Plm::CreditUnitsImporter
  include Common

  private

  def update_credit_units(parser)
    parser.credit_units_data.each do |discipline, credit_units_data|
      discipline.update_attribute :credit_units, credit_units_data
    end
  end

  def import_actions(parser)
    update_credit_units(parser)
  end
end
