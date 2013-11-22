module Plm
  class CreditUnitsImporter
    include Common

    private

    def update_credit_units(parser)
      parser.credit_units_data.each do |discipline, hash|

        discipline.update_attributes :credit_units => hash[:credit_units], :identifier => hash[:identifier]
      end
    end

    def update_optionally_credit_units(parser)
      parser.credit_units_data.each do |discipline, credit_units_data|

      end
    end

    def import_actions(parser)
      update_credit_units(parser)
      update_optionally_credit_units(parser)
    end
  end
end
