# Copyright 2017 Ahmet Cetinkaya

# This file is part of bibparser.
# bibparser is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# bibparser is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
# You should have received a copy of the GNU General Public License
# along with bibparser. If not, see <http://www.gnu.org/licenses/>.


require_relative "bibparser"

def print_entry(entry)
 if entry[0] == "string"
   puts "#{entry[0]}"
 else
   puts "#{entry[0]} (#{entry[1]})"
 end
 tags = entry[2]
 tags.each_key do |key|
   puts "  #{key}: #{tags[key]}"
 end
end

def print_entries
  test_file = "./test.bib"
  entries = BibParser.new.parse(test_file)
  entries.each do |entry|
    print_entry(entry)
    puts ""
  end
end

def page_count
  test_file = "./test.bib"
  entries = BibParser.new.parse(test_file)
  count = 0
  entries.each do |entry|
    tags = entry[2]
    if tags and tags["pages"] != nil
      pages = tags["pages"].split("--").map{|p| p.to_i}
      count += 1 + pages[1] - pages[0]
    end
  end
  puts "Total page count: #{count}" # Should be 27
end

print_entries
page_count
