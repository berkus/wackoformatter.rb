#
#   Sections preset.
#   (two token classes in one file)
#   Breaks given text into hierarchy of
#   "wakaSections" tokens.
#
#   == Section level 1
#   === Section level 2
#   ...
#   ====== Section level 5
#
require 'ostruct'

module WookieFormat

## TITLE token
class Sections < Token
  def self.get_regexp_part
    "((^|\n)[\r\t ]*={2,6}.*)"
  end

  def self.detect( outer_text )
    matches = @@re.match(outer_text)
    return false unless matches

    return OpenStruct.new({
      :inner   => matches[2],
      :level   => matches[1].length-1,
      :text    => outer_text
    })
  end

  def glue
    # glue only if prev is Section header with lesser depth
    if @prev && @prev.is_a?(Sections) && @prev.data.level < @data.level
      return @prev.glue_child(self)
    end
    return false
  end

  # this is a hack to trim newlines after section markup
  def separate_trim_next_newline
    true
  end

  def separate_from_next( nxt )
    return "</div></div>";
  end

  def compile
    inner = @wf.to_html(data.inner, :default)
    glued = @wf.format_tree(@tree)
    css1 = @wf.css_prefix + "section" + @wf.css_suffix
    css2 = @wf.css_prefix + "section-content" + @wf.css_suffix

    @html = '<div class="' + css1 + '">' +
            "<h#{data.level}>" + inner + "</h#{data.level}>" +
            '<div class="' + css2 + '">' +
            glued
  end

  # add a break, if exporting to text
  def to_text
    return "\n" + "=" * (data.level+1) + " " + data.inner + "\n"
  end

  private

  #           1          2       3
  @@re = /^\s*(={2,6})\s*(.*?)\s*(==+)?\s*?$/

end

## CONTENT token
class SectionsContent < Token
  def glue
    return true if @data == ""
    # glue only if prev is Sections
    if @prev && @prev.is_a?(Sections)
      return @prev.glue_child(self)
    end
    return false
  end
end

end
