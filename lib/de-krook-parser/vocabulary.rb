module DeKrookParser
  module Vocabulary
    DATEX = RDF::Vocabulary.new("http://vocab.datex.org/terms#")
    SERVICE = RDF::Vocabulary.new("http://purl.org/ontology/service#")
    DSO = RDF::Vocabulary.new("http://purl.org/ontology/dso#")
    SCHEMA = RDF::Vocabulary.new("http://schema.org/")
    DCTERMS = RDF::Vocab::DC
    RDF = ::RDF
    RDFS = RDF::RDFS
    FOAF = RDF::Vocabulary.new("http://xmlns.com/foaf/0.1/")
    OWL = RDF::OWL
    GR = RDF::Vocabulary.new("http://purl.org/goodrelations/v1#")
  end
end
