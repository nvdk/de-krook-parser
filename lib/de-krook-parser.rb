require 'rubygems'
require 'bundler/setup'

require 'csv'
require 'linkeddata'
require 'net/http'
require 'pstore'
require 'net/http/persistent'
require 'logger'
require 'date'
require_relative 'de-krook-parser/vocabulary'
require_relative 'de-krook-parser/parsers'


module DeKrookParser
  LOGGER = Logger.new(STDOUT)
  LOGGER.level = Logger::INFO

  def self.parse(input_dir:, output_dir:, config:, base_iri:, mode:)
    year = DateTime.now.year
    files = {
      "Werk.csv": Parsers::Work,
      "Locatie.csv": Parsers::Location,
      "Exemplaar.csv": Parsers::Expression,
      "Uitlening_Lener_#{year}.csv": Parsers::Loan,
      "Uitlening_Tijd_#{year}.csv": Parsers::LoanTime
    }
    files.each do |file, parser|
      LOGGER.info file
      parse_file(
       path: File.join(input_dir,file.to_s),
       parser: parser,
       mode: mode,
       output_dir:output_dir,
       base_iri: base_iri,
       config: config
      )
     config.transaction do
       config[:date] = DateTime.now.to_s
     end
    end
  end

  def self.parse_file(path:, parser:, mode:, output_dir:, base_iri:, config:)
    config.transaction do
      index = 0
      if mode == :incremental
        index = config[:last_run][File.basename(path)]
        LOGGER.info "truncating file #{path} to index #{index}"
        truncate_file(path, index)
      end
      begin
        tmp_file = parser.parse(base_iri, path, )
        FileUtils.copy(tmp_file, File.join(output_dir,File.basename(path) + ".ttl"))
        line_count=`wc -l #{path}`
        config[:last_run][File.basename(path)] = line_count
      rescue Exception => e
        LOGGER.error "error encountered during parsing of #{path}"
        LOGGER.error e
        # TODO: reset index?
      end
    end
  end

  def self.truncate_file(path, index)
  `head -n 1 #{path} > #{path}.truncated && tail -n +#{index} #{path} >> #{path}.truncated && mv #{path}.truncated #{path}`
  end
end

