module IntacctRuby
  module Functions
    # update customer instance
    class UpdateCustomer < CustomerBaseFunction
      include ContactsHelper

      def initialize(attrs = {})
        super "update_customer_#{attrs[:id]} (#{timestamp})", attrs
      end

      def to_xml
        super do |xml|
          xml.update_customer customerid: @attrs[:customerid] do
            xml << customer_params
          end
        end
      end
    end
  end
end
