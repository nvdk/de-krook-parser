module DeKrookParser
  module Parsers
    class Expression < CSV
      include DeKrookParser::Parsers::KrookHelpers
      MAPPING = { 
        "BKBarcode": SCHEMA.serialNumber,
        "BBNummer": DCTERMS.identifier,
        "Plaatskenmerk": SCHEMA.sku,
        "DatumInvoer": DCTERMS.issued,
        "StartDatum": SCHEMA.validFrom,
        "EindDatum": SCHEMA.validThrough
      }

      def self.parse(baseIRI, filepath)
        expression_parser = Expression.new(mapping: MAPPING, baseIRI: baseIRI , keyColumn: "ExemplaarID")
        expression_parser.parse(filepath)
      end

      def parse_row(index, row)
        iri = row_iri(index,row)
        quick_map = row.map{ |key, val| cell_to_triples(iri, key, val) }.reject(&:"nil?")
        logger.debug "#{quick_map.size} statements derived from mapping"
        quick_map | type_triples(iri, row) | purl_triples(iri) | links_to_others(iri, row)
      end
      
      def links_to_others(iri, row)
       graph = []
       graph << [book_uri(row["WerkID"]), SCHEMA.offers, iri ]
       graph << [iri, SCHEMA.offeredBy, map_location_to_agent(row["Locatie"]) ] unless is_empty?(row["Locatie"])
       graph << [iri, SCHEMA.availableAtOrFrom, location_uri(row["LocatieID"]) ]
      end

      def type_triples(iri, row)
        [ 
          [ iri, RDF.type, SCHEMA.Offer ],
          [ iri, SCHEMA.businessFunction, GR.LeaseOut ]
        ]
      end

      def row_iri(index, row)
        id = row[keyColumn]
        offer_uri(id)
      end
    end
  end
end
