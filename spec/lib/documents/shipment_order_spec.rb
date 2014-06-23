require 'spec_helper'

module Documents
  describe ShipmentOrder do
    let(:shipment) { Factories.shipment['shipment'] }

    subject { ShipmentOrder.new(shipment, {}) }

    it 'converts to xml' do
      xml = Nokogiri::XML(subject.to_xml)
      xsd = Nokogiri::XML::Schema(File.read('./spec/schemas/shipment_order.xsd'))

      errors = xsd.validate(xml).collect { |error| error }

      expect(subject.name).to match /_ShipmentOrder_12836/
      expect(errors).to eq []
    end
  end
end