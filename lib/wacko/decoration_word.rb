#
#   Decoration single word markup:
#
#   ^^superscript^^
#   vvSUBSCRIPTvv
#
require 'ostruct'

class DecorationWord < Token
  def self.get_regexp_part
    "(\\^\\^(\\S+)\\^\\^)"+
    "|"+
    "(vv(\\S+)vv)"
  end

  def self.detect( outer_text )
    matches = @@re.match( outer_text )
    if matches
      return OpenStruct.new({
        :inner   => matches[3],
        :typetag => matches[2],
        :text    => outer_text
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

  #        12         3
  @@re = /^((\^|v){2})(.*)\1$/

  @@tagMap = { "v" => "sub", "^" => "sup" }

end
