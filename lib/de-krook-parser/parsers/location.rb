module DeKrookParser
  module Parsers
    class Location < CSV
      include DeKrookParser::Parsers::KrookHelpers
      MAPPING = { 
                 "BKSublocatie": SCHEMA.branchCode,
                 "Groepering": SCHEMA.description
      }

      def self.parse(baseIRI, filepath)
        expression_parser = Location.new(mapping: MAPPING, baseIRI: baseIRI , keyColumn: "LocatieID")
        expression_parser.parse(filepath)
      end

      def parse_row(index, row)
        iri = row_iri(index,row)
        quick_map = row.map{ |key, val| cell_to_triples(iri, key, val) }.reject(&:"nil?")
        logger.debug "#{quick_map.size} statements derived from mapping"
        quick_map | type_triples(iri, row) | purl_triples(iri) | funky_mapping(iri, row)
      end
      
      def funky_mapping(iri, row)
       graph = []
       graph << [iri, SCHEMA.name, "#{row["BKLocatie"]} #{row["BKSubLocatie"]}" ]
       graph << [iri, DCTERMS.subject, location_subject(row["FictieOfNonFictie"]) ] unless is_empty?(row["FictieOfNonFictie"])
       graph << [iri, SCHEMA.availableAtOrFrom, location_uri(row["LocatieID"]) ]
       agent = map_location_to_agent(row["BKLocatie"])
       if agent
         graph << [ agent, RDF.type, SCHEMA.Organization ]
         graph = graph + purl_triples(agent)
         graph << [ agent, SCHEMA.name, row["BKLocatie"] ]
         location = agent_location(agent)       
         graph << [ agent, SCHEMA.location, location  ]
         graph << [ location, SCHEMA.containsPlace, iri ]
         graph += purl_triples(location)
       end
       graph  
      end

      def type_triples(iri, row)
        [ 
          [ iri, RDF.type, SCHEMA.Place ]
        ]
      end

      def row_iri(index, row)
        id = row[keyColumn]
        location_uri(id)
      end
    end
  end
end
