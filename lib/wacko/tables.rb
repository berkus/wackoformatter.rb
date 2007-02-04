#
#  Tables preset.
#  (two token classes in one file)
#  Used to parse tables. First token
#  denotes whole table and switches
#  formatter to another preset, where
#  only "wakaTablesRow" tokens can appear.
#
#  #|
#  || cell1 | cell2 ||
#  || cell3 | cell4 ||
#  |#
#
#  #|| ... ||#
#
require 'ostruct'

module WookieFormat

## TABLE token
class Tables < Token
  def self.get_regexp_part
    "(#\\|{1,2}(.|\n)*?\\|{1,2}#)"
  end

  def self.detect( outer_text )
    matches = @@re.match(outer_text)
    return false unless matches

    return OpenStruct.new({
      :inner   => matches[2],
      :typetag => matches[1].length,
      :text    => outer_text
    })
  end

  def compile
    css = @wf.css_prefix + @@cssMap[data.typetag] + @wf.css_suffix
    inner = @wf.to_html(data.inner, :table)

    @html = '<table class="' + css + '">' + inner + '</table>'
  end

  private

  #         1           23                  v ruby bug, without \# escape its regex parser fails badly
  @@re = /^#(\|{1,2})\n*((.|\n)*?)\n*\|{1,2}\#$/
  @@cssMap = [ "", "usertable", "dtable" ]

end

## ROW + CELL token
class TablesRow < Token
  def self.get_regexp_part
    "\\|\\|(.|\n)*?\\|\\|"
  end

  def self.detect( outer_text )
    matches = @@re.match(outer_text)
    return false unless matches

    cells = matches[1].split("|").collect { |c| c.gsub(/^ ?\n+/, "").gsub(/\n+ ?$/, "") }

    return OpenStruct.new({
      :cells   => cells,
      :colspan => [ 1 ],
      :text    => outer_text
    })
  end

  # TODO: override "build" to build rows BEFORE compiling
  attr_accessor :colcount

  def glue
    count_columns

    return false unless @prev
    return false unless @prev.is_a?(TablesRow)

    # need to fix colspan
    if colcount > @prev.colcount
      # TODO: make a prettier logic of correct colspanning
      @prev.data.colspan[0] += 1

      # continue fixing colspan
      return @prev.glue
    end

    # need to expand this row
    if colcount < @prev.colcount
      @data.colspan[@data.cells.length - 1] = @prev.colcount - colcount + 1
    end

    count_columns
    return false
  end

  def compile
    # break into cells
    cells = data.cells
    celldata = []

    # compile data
    cells.each_with_index do |cell, i|
      colspan = ''
      colspan = ' colspan="' + data.colspan[i] + '"' if !data.colspan[i].nil? && data.colspan[i] > 1

      content = @wf.to_html(cell, @next_preset)
      celldata[i] = '<td' + colspan + '>' + content + '</td>'
    end

    @html = '<tr>' + celldata.join + '</tr>'
  end

  private

  #             12
  @@re = /^\|{2}((.|\n)*?)\|{2}$/

  def count_columns
    count = 0
    (0...data.cells.length).each { |i|
      if data.colspan[i]
        count += data.colspan[i]
      else
        count += 1
      end
    }
    @colcount = count
  end
end

end
