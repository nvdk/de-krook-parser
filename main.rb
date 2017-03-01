#!/usr/bin/env ruby
require 'optparse'
require 'ruby-progressbar'


## Options using optparse
options = {
  outputfile: "dekrook.ttl",
  inputfile: nil,
  base_iri: "http://qa.stad.gent/",
  append: false
}
opt_parser = OptionParser.new do |opt|
opt.banner = "Usage: #{__FILE__} [OPTIONS]"
  opt.separator ''
  opt.separator 'Options'

  opt.on('-o', '--outputfile OUTPUT_FILE', '(relative) filepath to store output, default "uitleningen.ttl"') do |file|
    options[:outputfile] = file
  end
  opt.on('-i', '--inputfile INPUT_FILE', '(relative) filepath to the file to be parsed, REQUIRED') do |file|
    options[:inputfile] = file
  end
  opt.on('-a','--append', 'append to output file instead of overwriting') do
    options[:append] = true
  end
  opt.on('-b', '--base-iri', 'base IRI to be used for creating resources, default "http://qa.stad.gent/"') do |iri|
    options[:base_iri] = iri
  end
  opt.on('-h', '--help', 'help') do
    puts opt_parser
    options[:help] = true
  end
end

begin
  opt_parser.parse!
  mandatory = [:inputfile]
  missing = mandatory.select{ |param| options[param].nil? } 
  unless missing.empty?                                           
    raise OptionParser::MissingArgument.new(missing.join(', '))
  end                                                          
rescue OptionParser::InvalidOption, OptionParser::MissingArgument 
  puts $!.to_s
  puts opt_parser
  exit                                                            
end
  
filepath = options[:inputfile]
outputfile = options[:outputfile]
baseIRI = options[:base_iri]
write_mode = options[:append] ? "a" : "w"

