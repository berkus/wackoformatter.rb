#
#   Special symbols markup:
#
#   --      -> &mdash;
#   ---     -> <br />
#   ----    -> <hr />
#   <       -> &lt;
#   \n      -> <br />
#
require 'ostruct'

module WookieFormat

class Symbols < Token
  def self.get_regexp_part
    "(-{2}-+)"+
    "|"+
    "(\n)"+
    "|"+
    "(<)"+
    "|"+
    "(\\s--\\s)"
  end

  def self.detect( outer_text )
    result = OpenStruct.new({:tag => true, :text => outer_text})

    matches = @@re.match(outer_text)
    if matches
      # Bug, for some reason matches[0] and matches[1] are equal here when matching this---text :\
      if matches[0] == '---'
        result.inner = "br /"
      else
        result.inner = "hr noshade=\"noshade\" size=\"1\""
      end
    else
      if outer_text == "\n"
        result.inner = "br /"
      elsif outer_text == "<"
        result.tag = false
        result.inner = "&lt;"
      else
        result.tag = false
        result.inner = " &mdash; "
      end
    end

    return result
  end

  def compile
    result = @data.inner
    result = "<#{result}>" if @data.tag
    @html = result
  end

  private

  #            1
  @@re = /^-{3}(-*)$/

end

end
