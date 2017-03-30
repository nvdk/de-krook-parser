# de krook parser

A ruby project to convert the open data dumps from de krook to linked open data. Where possible books are linked to a book on oclc.org

## requirements
- (j)ruby 2.x
- bundle

## running as ruby

```
$ bundle
$ bin/parser -h
Usage: bin/parser [OPTIONS]

Options
    -o, --outputfile OUTPUT_PATH     (relative) filepath to store output, default "."
    -i, --inputfile INPUT_PATH       (relative) filepath to the files to be parsed, REQUIRED
    -f, --full                       do a full conversion instead of starting after last parsed location
    -b, --base-iri                   base IRI to be used for creating resources, default "http://qa.stad.gent/"
    -c, --config                     PATH to config file, default "./krook-parser.store"
    -h, --help                       help

```

## packaging to a jar
The project can be packaged as a jar using warbler:

```
gem install warbler
warble jar
java -jar de-krook-parser.jar -h
Usage: uri:classloader:/dekrook-parser/bin/parser [OPTIONS]

Options
    -o, --outputfile OUTPUT_PATH     (relative) filepath to store output, default "."
    -i, --inputfile INPUT_PATH       (relative) filepath to the files to be parsed, REQUIRED
    -f, --full                       do a full conversion instead of starting after last parsed location
    -b, --base-iri                   base IRI to be used for creating resources, default "http://qa.stad.gent/"
    -c, --config                     PATH to config file, default "./krook-parser.store"
    -h, --help                       help

```

## license

See [License](LICENSE)
