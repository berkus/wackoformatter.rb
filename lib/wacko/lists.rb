#
#   Ordered and unordered lists markup:
#
#   * two spaces and asterisk
#   * one more
#     1. plus two spaces
#     2. number-dot
#   * list item
#
#   1.#9 custom numeration supported
#
require 'ostruct'

module WookieFormat

class Lists < Token
  def self.get_regexp_part
    "((^|\n)(  )*(\\*|[0-9]+\\.)(#[0-9]+)? .*)"
  end

  def self.detect( outer_text )
    matches = @@re.match(outer_text)
    return false unless matches

    li_type = "ul"
    li_type = "ol" if matches[4]

    return OpenStruct.new({
      :inner   => matches[6],
      :typetag => li_type,
      :level   => matches[1].length/2,
      :start   => matches[5] ? matches[5][1..-1] : false,
      :text    => outer_text
    })
  end

  def glue
    # glue only if prev is List with lesser depth
    if @prev && @prev.is_a?(Lists) && @prev.data.level < @data.level
      return @prev.glue_child(self)
    end
    return false
  end

  # this is a hack to trim newlines after <li>
  def separate_trim_next_newline
    true
  end

  def separate_from_next( nxt )
    return "</#{data.typetag}>" if !nxt || !nxt.is_a?(Lists) || nxt.data.typetag != data.typetag
    return ""
  end

  def compile
    inner = @wf.to_html(data.inner, :default)
    glued = @wf.format_tree(@tree)

    list_start_if_any = ""
    if !@prev || !@prev.is_a?(Lists) || @prev.data.typetag != data.typetag
      list_start_if_any = "<#{data.typetag}#{data.start ? " start=\""+data.start.to_s+"\" " : ""}>"
    end

    @html = list_start_if_any + "<li>" + inner + glued + "</li>"
  end

  private

  #           12     3   4          5          6
  @@re = /^\n?((  )*)(\*|([0-9]+\.))(#[0-9]+)? (.*)$/

end

end
