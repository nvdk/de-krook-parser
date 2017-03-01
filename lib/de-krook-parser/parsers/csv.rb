require 'tempfile'

module DeKrookParser
  module Parsers
    class CSV
      LOGGER = Logger.new(STDOUT)
      LOGGER.level = Logger::WARN

      attr_reader :encoding, :mapping, :baseIRI, :keyColumn, :columnCount
      
      def initialize(encoding: 'iso-8859-1', mapping: {}, baseIRI:, keyColumn: nil )
        logger.info "parser initialized"
        logger.info "encoding: #{encoding.inspect}, mapping:#{mapping.inspect}, baseIRI:#{baseIRI.inspect}, keyColumn: #{keyColumn.inspect}"
        @encoding = encoding
        @mapping = mapping
        @baseIRI = baseIRI
        @keyColumn = keyColumn
      end

      def parse(filepath)
        index = 0
        output = Tempfile.new("parse-of-#{File.basename(filepath)}")
        output.write "# parsing #{filepath}"
        begin
        ::CSV.foreach(filepath, csv_parse_options) do |row|
          if index == 0
            @columnCount = row.size
            index += 1
            next
          end
          ensure_valid_row(row, index) do |row|
            repo = RDF::Repository.new do |graph| 
              parse_row(index, row).each do |statement|
                logger.debug statement.inspect
                graph << statement
              end
            end
            output.write(repo.dump(:ttl))
          end
          index += 1
        end
        rescue ::CSV::MalformedCSVError => e
          logger.error e.message
          logger.error "parsing stopped after this error"
        end
        output.close
        output
      end

      def logger
        LOGGER
      end

      def parse_row(index, row)
       row.map do | key, val |
          [ row_iri(index,row) , column_to_predicate(key), val ]
        end
      end

      def is_valid_key?(key)
        not is_empty?(key)
      end

      def ensure_valid_row(row, index, &block) 
        errors = 0
        if row.size > columnCount
          logger.warn "ignored row #{row.count}: has more columns than expected #{row.size} > #{columnCount} "
          errors += 1
        end
  
        if row.size < columnCount
          logger.warn "ignored row #{row.count}: has more columns than expected #{row.size} < #{columnCount} "
          errors += 1
        end
  
        unless keyColumn.nil? or is_valid_key?(row[keyColumn])
          logger.warn "ignored row #{index}: has invalid key #{row[keyColumn]} for column #{keyColumn}"
          errors += 1
        end

        if errors == 0
          block.call(row)
        end
      end

      protected
      def csv_parse_options
        { headers: :first_row, return_headers: true, encoding: @encoding, skip_lines: /[^\x00-\x7F]/ }
      end

      def column_to_predicate(key)
        mapping[key.to_sym] or RDF::URI.new("#{baseIRI}predicates/#{key}")
      end
      
      def row_iri(index, row)
        if keyColumn.nil?
          RDF::URI.new("#{baseIRI}rows/#{index}")
        else
          RDF::URI.new("#{baseIRI}rows/#{row[keyColumn]}")
        end
      end
      
      def is_empty?(val)
        val.nil? or val.to_s.empty?
      end
    end
  end
end
