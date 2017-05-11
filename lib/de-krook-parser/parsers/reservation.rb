require 'securerandom'
module DeKrookParser
  module Parsers
    class Reservation < CSV
      include DeKrookParser::Parsers::KrookHelpers
      MAPPING = {
        "DatumIngang": SCHEMA.bookingTime
      }

      def self.parse(baseIRI, filepath, index = 0)
        parser = Reservation.new(mapping: MAPPING, baseIRI: baseIRI)
        parser.parse(filepath, index)
      end

      def parse_row(index, row)
        iri = row_iri(index,row)
        quick_map = row.map{ |key, val| cell_to_triples(iri, key, val) }.reject(&:"nil?")
        logger.debug "#{quick_map.size} statements derived from mapping"
        quick_map | type_triples(iri, row) | purl_triples(iri) | links_to_others(iri, row)
      end
      
      def links_to_others(iri, row)
       graph = []
       graph << [ iri, SCHEMA.reservationFor, offer_uri(row["ExemplaarID"]) ]
       graph << [ iri, SCHEMA.provider, agent_uri(Digest::MD5.hexdigest(row["AfhaalLocatie"])) ]
      end

      def type_triples(iri, row)
        [ 
          [ iri, RDF.type, SCHEMA.Reservation ]
        ]
      end

      def row_iri(index, row)
        id = SecureRandom.uuid
        reservation_uri(id)
      end
    end
  end
end
