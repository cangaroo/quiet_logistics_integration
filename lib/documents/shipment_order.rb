module Documents
  class ShipmentOrder
    attr_reader :shipment_number, :order, :shipment, :name, :unit

    def initialize(shipment, config)
      @config          = config
      @shipment        = shipment
      @shipment_number = shipment['id']
      @name            = "#{@config['business_unit']}_ShipmentOrder_#{@shipment_number}_#{date_stamp}.xml"
    end

    def to_xml
      builder = Nokogiri::XML::Builder.new do |xml|
        xml.ShipOrderDocument('xmlns' => 'http://schemas.quietlogistics.com/V2/ShipmentOrder.xsd') {

          xml.ClientID @config['client_id']
          xml.BusinessUnit @config['business_unit']

          xml.OrderHeader('OrderNumber' => @shipment_number,
                          'OrderType'   => 'SO',
                          'OrderDate'   => DateTime.now.iso8601) {

            xml.Extension shipment['order_number']

            xml.Comments shipment['comments'].to_s

            xml.ShipMode('Carrier'      => @shipment['carrier'],
                         'ServiceLevel' => @shipment['service_level'])

            xml.ShipTo(ship_to_hash)
            xml.BillTo(bill_to_hash)

            xml.Notes('NoteType' => @shipment['note_type'].to_s, 'NoteValue' => @shipment['note_value'].to_s)
          }

          @shipment['items'].collect do |item|
            xml.OrderDetails(line_item_hash(item))
          end
        }
      end
      builder.to_xml
    end

    def line_item_hash(item)
      {
        'ItemNumber'      => item["sku"],
        'Line'            => @shipment['items'].find_index(item),
        'QuantityOrdered' => item['quantity'],
        'QuantityToShip'  => item['quantity'],
        'UOM'             => 'EA',
        'Price'           => item['price']
      }
    end

    def ship_to_hash
      {
        'Company'    => full_name,
        'Contact'    => @shipment['shipping_address']['contact'],
        'Address1'   => @shipment['shipping_address']['address1'],
        'City'       => @shipment['shipping_address']['city'],
        'State'      => @shipment['shipping_address']['state'],
        'PostalCode' => @shipment['shipping_address']['zipcode'],
        'Country'    => @shipment['shipping_address']['country']
      }
    end

    def bill_to_hash
      {
        'Company'    => full_name,
        'Contact'    => @shipment['shipping_address']['contact'],
        'Address1'   => @shipment['shipping_address']['address1'],
        'City'       => @shipment['shipping_address']['city'],
        'State'      => @shipment['shipping_address']['state'],
        'PostalCode' => @shipment['shipping_address']['zipcode'],
        'Country'    => @shipment['shipping_address']['country']
      }
    end

    def full_name
      "#{shipment['shipping_address']['firstname']} #{@shipment['shipping_address']['lastname']}"
    end

    def message
      "Succesfully Sent Shipment #{@shipment_number} to Quiet Logistics"
    end

    def date_stamp
      Time.now.strftime('%Y%m%d_%H%M%3N')
    end
  end
end
