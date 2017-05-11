require 'digest/md5'

module DeKrookParser::Parsers::KrookHelpers
  include DeKrookParser::Vocabulary
  EMPTY_VAL = "-"

  def cell_to_triples(iri, key, val)
    if mapping.has_key?(key.to_sym) and not is_empty?(val)
      [ iri , column_to_predicate(key), val ]
    end   
  end   

  def book_uri(id)
   RDF::URI("#{baseIRI}id/dekrook/works/#{id}")
  end

  def offer_uri(id)
   RDF::URI("#{baseIRI}id/dekrook/offers/#{id}")
  end

  def loan_uri(id)
    RDF::URI("#{baseIRI}id/dekrook/loans/#{id}")
  end

  def subscription_uri(id)
    RDF::URI("#{baseIRI}id/dekrook/subscription/#{id}")
  end
  
  def location_subject(subj)
    RDF::URI("#{baseIRI}/id/dekrook/subjects/#{subj}")
  end
  
  def purl_triples(iri)
     [[ iri, RDFS.isDefinedBy, RDF::URI.new(iri.to_s.gsub(/\/id\//,'/data/')) ]]
  end  
  
  def location_uri(id)
    RDF::URI("#{baseIRI}id/dekrook/location/#{id}")
  end

  def agent_uri(id)
    RDF::URI("#{baseIRI}id/dekrook/agents/#{id}")
  end

  def reservation_uri(id)
    RDF::URI("#{baseIRI}id/dekrook/reservations/#{id}")
  end
  
  def agent_location(iri)
    RDF::URI.new(iri.to_s.gsub(/\/agents\//,'/locations/'))
  end

  def map_location_to_agent(name)
    iri = agent_uri(Digest::MD5.hexdigest(name.strip))
  end
  protected
  def is_empty?(value)
    super || value == EMPTY_VAL 
  end

end
