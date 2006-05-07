#
#   Decoration multiline markup,
#   that glues to words:
#
#   --strike out--
#   !!color highlighting!!
#   ??background hightlighting??
#
#   ??(red)background??
#
#   -- must not work in such cases (see leading space?)--
#
require 'ostruct'

class DecorationGlue < Token
  def self.get_regexp_part
    "((^|\\s)--[^ \t\n\r\\-]((.|\n)*?[^ \t\n\r\\-])?--($|\\s|[,.!\\?]))"+
    "|"+
    "((^|\\s)!!\\S((.|\n)*?\\S)?!!($|\\s|[,.!\\?]))"+
    "|"+
    "((^|\\s)\\?\\?\\S((.|\n)*?\\S)?\\?\\?($|\\s|[,.!\\?]))"
  end

  def self.detect( outer_text )
    matches = @@re1.match(outer_text)
    if matches
      return OpenStruct.new({
        :whitespace_before => matches[1],
        :whitespace_after  => matches[6],

        :inner   => matches[4],
        :typetag => '-',
        :text    => outer_text
      })
    end

    matches = @@re2.match(outer_text)
    if matches
      _css = 'back'
      _css = 'fore' if matches[3] == '!'
      _css += '-'+matches[5] if matches[5]

      return OpenStruct.new({
        :whitespace_before => matches[1],
        :whitespace_after  => matches[8],

        :inner   => matches[6],
        :typetag => matches[3],
        :css     => _css,
        :text    => outer_text
      })
    end

    false
  end

  def compile
    inner = @wf.to_html(@data.inner, :default)

    if @data.typetag == '-'
      @html = "<s>#{inner}</s>"
    else
      @html = '<span class="'+@wf.css_prefix + @data.css + @wf.css_suffix + '">' + inner + '</span>'
    end

    @html = [@wf.to_html(@data.whitespace_before), @html].join  if @data.whitespace_before
    @html = [@html, @wf.to_html(@data.whitespace_after) ].join  if @data.whitespace_after
  end

  private

  #         1    23      45         67
  @@re1 = /^(\s?)((-){2})((.|\n)*)\2((\s|[,.!\\?])?)$/

  #         1    23         4  5                      67         89
  @@re2 = /^(\s?)((\?|!){2})(\((red|blue|green)\)\s*)?((.|\n)*)\2((\s|[,.!\\?])?)$/

end
