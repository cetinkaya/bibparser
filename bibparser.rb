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


class BibParser
  def parse(text)
    if FileTest.exists?(text)
      text = File.read(text)
    end
    regex = /(@[a-zA-z]+|{|}|#|"|,|=)/
    @tokens = text.split(regex).map{|token| if token.strip.length > 1; token; else; token.strip; end}.find_all{|token| token.length > 0}
    @index = 0
    @vars = Hash.new("")
    entries = []
    while true
      break if reached_end?
      entries<< parse_entry
    end
    return entries
  end

  def reached_end?
    @index == @tokens.length
  end

  def get_token
    raise "Error in parsing." if @index >= @tokens.length
    token = @tokens[@index]
    @index += 1
    token
  end

  def peek_token
    raise "Error in parsing." if @index >= @tokens.length
    token = @tokens[@index]
    token
  end

  def get_specific_token(tok)
    token = get_token
    raise "Was expecting #{tok}, but got #{token} instead." unless token == tok
    token
  end

  def parse_citation_key
    key = get_token
    get_specific_token(",")
    key
  end

  def parse_tag
    name = get_token.strip
    get_specific_token("=")
    content = parse_content
    [name, content]
  end

  def parse_content
    content = ""
    while true
      if peek_token == ","
        get_token
        break
      end
      break if peek_token == "}"
      if peek_token == "\""
        content += parse_string
      elsif peek_token == "{"
        content += parse_block
      elsif peek_token == "#"
        get_token
        var = get_token.strip
        content += @vars[var]
      else
        var = get_token.strip
        content += @vars[var]
        get_specific_token("#")
      end
    end
    content
  end

  def parse_string
    get_specific_token("\"")
    string = ""
    while true
      break if peek_token == "\""
      string += get_token
    end
    get_specific_token("\"")
    string
  end

  def parse_block(with_brackets=false)
    get_specific_token("{")
    string = ""
    while true
      break if peek_token == "}"
      if peek_token == "{"
        string += parse_block(true)
      else
        string += get_token
      end
    end
    get_specific_token("}")
    if with_brackets
      "{" + string + "}"
    else
      string
    end
  end

  def parse_tags
    tags = {}
    while true
      break if peek_token == "}"
      name, content = *parse_tag
      tags[name] = content
    end
    return tags
  end

  def parse_entry
    type = get_token[1..-1].downcase
    raise "Cannot parse preamble or comment entries!" if ["preamble", "comment"].index(type)
    if type == "string"
      get_specific_token("{")
      tags = parse_tags
      tags.each_key do |key|
        @vars[key] = tags[key]
      end
      get_specific_token("}")
      return [type, "", tags]
    else
      get_specific_token("{")
      citation_key = parse_citation_key
      tags = parse_tags
      get_specific_token("}")
      return [type, citation_key, tags]
    end
  end
end
