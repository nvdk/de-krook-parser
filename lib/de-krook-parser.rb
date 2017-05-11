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

  def self.parse(input_dir:, output_dir:, config:, base_iri:, mode:, year:, type: )
    year = year
    files = {
      "Werk.csv": Parsers::Work,
      "Locatie.csv": Parsers::Location,
      "Exemplaar.csv": Parsers::Expression,
      "Uitlening_Lener_#{year}.csv": Parsers::Loan,
      "Uitlening_Tijd_#{year}.csv": Parsers::LoanTime
    }
    unless (type == "all")
      files.keep_if { |key,value| key.to_s.downcase.include?(type.downcase)}
    end
    LOGGER.info "the files #{files} will be parsed"
    LOGGER.warn "no files selected for type #{type}" unless files.length > 0
    files.each do |file, parser|
      LOGGER.info file.to_s
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
    cleanup_file(path)
    config.transaction do
      index = 0
      line_count=`wc -l #{path} | awk '{ print $1 }'`
      if mode == :incremental && config[:last_run][File.basename(path)].to_i > 0
        index = config[:last_run][File.basename(path)].to_i        
        LOGGER.info "truncating file #{path} to index #{index}"
        truncate_file(path, index)
    end
    LOGGER.warn "running full/initial conversion of #{File.basename(path)} dataset, may take a long time" unless index > 0
    begin
        tmp_file = parser.parse(base_iri, path, index )
        FileUtils.copy(tmp_file, File.join(output_dir,File.basename(path) + ".ttl"))
        config[:last_run][File.basename(path)] = line_count
        tmp_file.unlink
      rescue Exception => e
        LOGGER.error "error encountered during parsing of #{path}"
        LOGGER.error e
        # TODO: reset index?
      end
    end
  end

  def self.cleanup_file(path)
    `sed -i '/ge&/d' #{path}`
  end

  def self.truncate_file(path, index)
  `head -n 1 #{path} > #{path}.truncated && tail -n +#{index} #{path} >> #{path}.truncated && mv #{path}.truncated #{path}`
  end
end

