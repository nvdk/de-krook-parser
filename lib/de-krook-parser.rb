require 'csv'
require 'linkeddata'
require 'net/http'
require 'pstore'
require 'net/http/persistent'
require 'logger'

require_relative 'de-krook-parser/vocabulary'
require_relative 'de-krook-parser/parsers'


module DeKrookParser
  DEFAULT_PARSE_OPTIONS = {file_path: __FILE__, append: false, output_path: 'temp.ttl'}
  def self.parse(options)
    parse_options = DEFAULT_PARSE_OPTIONS.merge options
    werkpath= File.join(parse_options[:file_path],'Werk.csv')
    werken = Parsers::Werk.parse(werkpath)
  end
end

