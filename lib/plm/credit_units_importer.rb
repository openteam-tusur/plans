module Plm
  class CreditUnitsImporter
    include Common

    private

    def update_credit_units(parser)
      parser.credit_units_data.each do |discipline, hash|
        discipline.reload.update_attribute :identifier, hash[:identifier]

        if hash[:credit_units].any?
          discipline.update_attribute :credit_units, hash[:credit_units]
          update_optionally_credit_units(discipline)
        end
      end
    end

    def update_optionally_credit_units(discipline)
      discipline.optionally_disciplines_with_empty_credit_units.each { |d| d.update_attribute :credit_units, discipline.credit_units }
    end

    def import_actions(parser)
      update_credit_units(parser)
    end
  end
end
