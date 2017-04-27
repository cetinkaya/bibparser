# bibparser
bibparser is a simple [BibTeX](http://www.bibtex.org) file parsing library implemented in ruby. 

Currently, bibparser can only parse publicaton type (@article, @book, etc.) and "@string" entries. It gives error when it sees @preamble or @comment entries. 

Given a .bib file or a BibTeX string, bibparser's parse method returns in an array of all parsed entries. Each element of the array is itself an array of 3 elements: `EntryType`, `CitationKeyIfTheEntryIsAPubliction`, and `Tags`. 

## Example Use

bibparser is far from being complete, but it can be used for simple processing needs. For instance, bibparser can be used in the following way to see the total page count of all publications in a BibTeX bibliography file `test.bib`. 

``` ruby
require_relative "bibparser"

entries = BibParser.new.parse("./test.bib")

count = 0
entries.each do |entry|
  tags = entry[2]
  if tags and tags["pages"] != nil
    pages = tags["pages"].split("--").map{|p| p.to_i}
    count += 1 + pages[1] - pages[0]
  end
end

puts "Total page count: #{count}" # Should be 27
```
