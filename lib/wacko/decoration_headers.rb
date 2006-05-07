#
#   Headers (as decoration) markup:
#
#   ==H1 header==
#   ===H2 header==
#   ...
#   =======H6 header==
#
require 'ostruct'

module WookieFormat

class DecorationHeaders < Token
  def self.get_regexp_part
    "((^|\n)[\r\t ]*={2,7}.*?==+)"
  end

  def self.detect( outer_text )
    matches = @@re.match(outer_text)
    return false unless matches
    return false if matches[2] == '=' # Empty header
    return OpenStruct.new({:inner => matches[2], :level => matches[1].length-1, :text => outer_text})
  end

  def compile
    inner = @wf.to_html(@data.inner, :default)
    @html = "<h#{@data.level}>#{inner}</h#{@data.level}>"
  end

  private

  #           1          2
  @@re = /^\s*(={2,7})\s*(.+?)\s*==+$/

end

end
