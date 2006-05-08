#
#   Email quotation:
#
#   > Level one quotation
#   >> Level two
#   >>> Level three and so on
#
#   could be tuned by next parameters:
#
#   @@html_quote_sign -- each line would start with this character/string
#   @@html_quote_glue -- if "true", several lines with one level
#                        will be treated as one
#
require 'ostruct'

module WookieFormat

class EmailQuotes < Token
  @@html_quote_sign = ""
  @@html_quote_glue = true

  def self.get_regexp_part
    "((^|\n) ?(> ?)+.+)"
  end

  def self.detect( outer_text )
    matches = @@re.match(outer_text)
    return false unless matches

    level_str = matches[3].gsub(/\s/, '')

    return OpenStruct.new({
      :inner => matches[5],
      :level => level_str.length,
      :text  => outer_text
    })
  end

  def glue
    # glue only if prev is EmailQuote with lesser depth
    if @prev && @prev.is_a?(EmailQuotes) && @prev.data.level < @data.level
      return @prev.glue_child(self)
    end
    return false
  end

  def separate_trim_next_newline
    true
  end

  # returns separation from a given "next"
  def separate_from_next( nxt )
    return "</div>" if !nxt || !nxt.is_a?(EmailQuotes) || nxt.data.level != data.level || !@@html_quote_glue
    return ""
  end

  def compile
    inner = @wf.to_html(data.inner, :default)
    glued = @wf.format_tree(@tree)

    list_start_if_any = ""
    if !@prev || !@prev.is_a?(EmailQuotes) || @prev.data.level != data.level || !@@html_quote_glue
      sign = ""
      sign = @@html_quote_sign * data.level if @@html_quote_sign != ""
      _css = @wf.css_prefix + "email" + (data.level % 2).to_s + @wf.css_suffix
      list_start_if_any += "<div class=\"#{_css}\">#{sign}"
    end

    @html = list_start_if_any + inner + glued
  end

  private

  #           12       34      5
  @@re = /^\n?((^|\n) ?((> ?)+)(.+))$/

end

end
