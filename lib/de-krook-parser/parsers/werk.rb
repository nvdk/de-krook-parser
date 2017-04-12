module DeKrookParser
  module Parsers
    class Work < CSV
      include DeKrookParser::Parsers::KrookHelpers

      EMPTY_VAL = "-"
      MAPPING = { 
        "ISBN": SCHEMA.productID,
        "TaalPublicatie": SCHEMA.inLanguage,
        "BKBBNummer": DCTERMS.identifier,
        "OpenVlaccID": DCTERMS.identifier,
        "Leeftijd": SCHEMA.typicalAgeRange,
        "Editie": SCHEMA.bookEdition,
        "JaarVanUitgave": SCHEMA.datePublished,
        "Titel": SCHEMA.name
      }

      def self.parse(baseIRI, filepath, index = 0)
        work_parser = Work.new(mapping: MAPPING, baseIRI: baseIRI , keyColumn: "WerkID")
        work_parser.parse(filepath, index)
      end

      def parse_row(index, row)
        iri = row_iri(index,row)
        quick_map = row.map{ |key, val| cell_to_triples(iri, key, val) }.reject(&:"nil?")
        logger.debug "#{quick_map.size} statements derived from mapping"
        quick_map | worldcat_triples(iri, row) | type_triples(iri, row) | purl_triples(iri)
      end


      def type_triples(iri, row)
        graph = [ [ iri, RDF.type, SCHEMA.CreativeWork] ]
        workType = type_of_work(row["SoortMateriaal"])
        if workType
          graph << [ iri, RDF.type, workType ]
        end
        graph 
      end

      def worldcat_triples(iri, row)
        graph = []
        if valid_isbn?(row["ISBN"])
          worldcat = isbn_to_oclc(row["ISBN"])
          if worldcat
            graph << [ iri, FOAF.page, RDF::URI(worldcat) ]
            graph << [ iri, RDF::OWL.sameAs,  RDF::URI(worldcat.gsub(/title\/[^\/]+\//,'')) ]
          end
        end
        graph
      end

      def isbn_to_oclc(isbn)
        @oclc_store ||= PStore.new('isbn-to-oclc.store')
        @oclc_store.transaction do      
          @oclc_store['failed'] ||= []                                            
          unless @oclc_store[isbn] or @oclc_store['failed'].include?(isbn)
            worldcat_url = fetch_isbn_from_worldcat(isbn)
            if worldcat_url
              @oclc_store[isbn] = worldcat_url
            else
              @oclc_store['failed'] << isbn
            end
          end
          @oclc_store[isbn]
        end
      end

      def fetch_isbn_from_worldcat(isbn)
        begin
          Net::HTTP.start('www.worldcat.org', 80) do |http|
            response = http.head(URI("http://www.worldcat.org/isbn/#{isbn}"))
            if response['Location']
              response['Location']
            else
              nil
            end
          end
        rescue Exception => e
          logger.error "fetching worldcat for isbn #{isbn} failed: #{e.message}"
          logger.debug e.backtrace.join("\n")
          nil
        end
      end
         
      protected
      def is_valid_key?(value)
        super && value.to_i >= 0  
      end
            
      def row_iri(index, row)
        id = row[keyColumn]
        book_uri(id)
      end
    
      def valid_isbn?(isbn)
        isbn.to_i > 0 && isbn.length == 13 or isbn.length == 10
      end

      def type_of_work(materiaal)
        case materiaal
          when "CD" then SCHEMA.MusicRecording
          when "Boek" then SCHEMA.Book
          when "Strip" then SCHEMA.ComicStory
          when "DVD-Video" then SCHEMA.Movie
        end
      end
    end
  end
end
