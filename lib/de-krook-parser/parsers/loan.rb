require 'digest/md5'
module DeKrookParser
  module Parsers
    class Loan < CSV
      include DeKrookParser::Parsers::KrookHelpers
      MAPPING = {
        "LenerCategorie": SCHEMA.memberOf,
        "LenerGeboorteJaar": SCHEMA.birthDate,
        "LenerGeslacht": SCHEMA.gender,
        "LenerPostCode": SCHEMA.address
      }

      def self.parse(baseIRI, filepath, index = 0)
        expression_parser = Loan.new(mapping: MAPPING, baseIRI: baseIRI)
        expression_parser.parse(filepath, index)
      end

      def parse_row(index, row)
        iri = row_iri(index,row)
        quick_map = row.map{ |key, val| cell_to_triples(iri, key, val) }.reject(&:"nil?")
        logger.debug "#{quick_map.size} statements derived from mapping"
        quick_map | type_triples(iri, row) | purl_triples(iri) | links_to_others(iri, row)
      end
      
      def links_to_others(iri, row)
       subscription_iri = subscription_uri(Digest::MD5.hexdigest(row["LenerLocatieInschrijving"]+row["LenerMaandInschrijving"]))
       graph = []
       graph << [ iri, SERVICE.consumes, offer_uri(row["ExemplaarID"]) ]
       graph << [ iri, DATEX.hasSubscription, subscription_iri ]
       graph << [ subscription_iri, SCHEMA.offeredBy, agent_uri(Digest::MD5.hexdigest(row["LenerLocatieInschrijving"])) ]
       graph << [ subscription_iri, DATEX.subscriptionStartTime, row["LenerMaandInschrijving"] ]
      end

      def type_triples(iri, row)
        [ 
          [ iri, RDF.type, SCHEMA.Person ]
        ]
      end

      def row_iri(index, row)
        id = Digest::MD5.hexdigest(row["LenerCategorie"]+row["LenerGeboorteJaar"]+row["LenerGeslacht"]+row["LenerLocatieInschrijving"]+row["LenerMaandInschrijving"]+row["LenerPostCode"])
        agent_uri(id)
      end
    end
  end
end
