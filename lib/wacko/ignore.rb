#
#   Ignore markup:
#
#   ""ignore block""
#   ~ignoreNextWord
#   <waka31ignore>...</waka31ignore>
#
require 'ostruct'

class Ignore < Token
  def self.get_regexp_part
    "(\"\"((.|\n)*?)\"\")"+
    "|"+
    "([^\\s~]*~[^\\s~]*)"
  end

  def self.detect( outer_text )
    matches = @@re.match(outer_text)
    return false unless matches

    _inner = ""
    if matches[2]
      _inner = matches[3]
    else
      _inner = matches[5].gsub('~', '')
    end

    return OpenStruct.new({:inner => _inner, :text => outer_text})
  end

  def compile
    @html = "<#{@wf.ignoreTagName}>#{@data.inner}</#{@wf.ignoreTagName}>"
  end

  private

  @@re = /^(#{self.get_regexp_part})$/

end
