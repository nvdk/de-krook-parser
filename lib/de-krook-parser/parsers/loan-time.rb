require 'digest/md5'
module DeKrookParser
  module Parsers
    class LoanTime < CSV
      include DeKrookParser::Parsers::KrookHelpers
      MAPPING = {
        "DatumVan": SCHEMA.startDate,
        "DatumTot": SCHEMA.endDate,
      }

      def self.parse(baseIRI, filepath, index = 0)
        expression_parser = LoanTime.new(mapping: MAPPING, baseIRI: baseIRI)
        expression_parser.parse(filepath, index)
      end

      def parse_row(index, row)
        iri = row_iri(index,row)
        quick_map = row.map{ |key, val| cell_to_triples(iri, key, val) }.reject(&:"nil?")
        logger.debug "#{quick_map.size} statements derived from mapping"
        quick_map | type_triples(iri, row) | purl_triples(iri) | links_to_others(iri, row)
      end
      
      def links_to_others(iri, row)
       graph = []
       graph << [ iri, SERVICE.consumes, offer_uri(row["ExemplaarID"]) ]
       graph << [ iri, SCHEMA.location, agent_uri(Digest::MD5.hexdigest(row["Locatie"])) ] unless is_empty?(row["Locatie"])
       graph
      end

      def date_triples(iri, row)
        graph = []
        if valid_date?(row["DatumVan"]) && valid_date?(row["DatumTot"])
          graph << [ iri, SCHEMA.startDate, RDF::Literal::DateTime.new(row["DatumVan"]) ]
          graph << [ iri, SCHEMA.endDate, RDF::Literal::DateTime.new(row["DatumTot"]) ]
        end
        graph
      end

      def type_triples(iri, row)
        [ 
          [ iri, RDF.type, DSO.Loan ]
        ]
      end

      def valid_date?(datestring)
        begin
          DateTime.parse(datestring)
          true
        rescue
          false
        end
      end

      def row_iri(index, row)
        id = Digest::MD5.hexdigest(row["ExemplaarID"]+row["Locatie"]+row["Barcode"]+row["DatumVan"]+row["DatumTot"])
        loan_uri(id)
      end
    end
  end
end
