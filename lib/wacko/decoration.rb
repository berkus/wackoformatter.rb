#
#   Decoration markup:
#
#   **bold**
#   //italic//
#   ++small++
#   ##monospace##
#   __underline__
#
#   <[ blockquotes ]>
#
require 'ostruct'

module WookieFormat

class Decoration < Token
  def self.get_regexp_part
    "(\\*\\*(.)*?\\*\\*)"+
    "|"+
    "(\\/\\/(.)*?\\/\\/)"+
    "|"+
    "(__(.)*?__)"+
    "|"+
    "(##(.)*?##)"+
    "|"+
    "(\\+\\+(.)*?\\+\\+)"+
#     "|"+
#     "(>>(.)*?<<)"+     // buggish one
    "|"+
    "(<\\[(.|\n)*?\\]>)"
  end

  def self.detect( outer_text )
    matches = @@re.match( outer_text )
    if matches
      return OpenStruct.new({
        :inner    => matches[3],
        :typetag  => matches[2],
        :text     => outer_text
      })
    end

#     matches = @@re2.match( outer_text )
#     if matches
#       return OpenStruct.new({
#         :inner    => matches[2],
#         :typetag  => ">>",
#         :text     => outer_text
#       })
#     end

    matches = @@re3.match( outer_text )
    if matches
      return OpenStruct.new({
        :inner    => matches[2],
        :typetag  => "<[",
        :text     => outer_text
      })
    end

    false
  end

  def compile
    tag = @@tagMap[@data.typetag]
    inner = @wf.to_html(@data.inner, :default)
    @html = "<#{tag}>#{inner}</#{tag}>"
  end

  private

  @@tagMap = { "/" => "i", "*" => "b", "+" => "small",
               "#" => "tt", "_" => "u",
               ">>" => "center",
               "<[" => "blockquote" }

  #         12                 3
  @@re  = /^((\*|\/|\+|#|_){2})(.*)\1$/;
  #         1  2
  @@re2 = /^(>>(.*)<<)$/;
  #         1      23
  @@re3 = /^(<\[\s*((.|\n)*?)\s*\]>)$/;

end

end
