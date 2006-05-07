#
#   Links and dfn markup:
#
#   http://yandex.ru
#   www.yandex.ru
#   mailto:mendokusee@gmail.com
#   mendokusee@gmail.com
#   google:waka
#
#   ((http://yandex.ru Yandex))
#   [[http://yandex.ru Yandex]]
#   ((google:waka poetry == What is waka))
#
#   (?dfn DFN means definition?)
#
require 'ostruct'
require 'uri/common'

module WookieFormat

class Links < Token
  @@open_in_new_window = true
  @@interwiki = {
    "yandex"    => "http://www.yandex.ru/yandsearch?rpt=rad&text=",
    "google"    => "http://www.google.com/search?q=",
    "wackowiki" => "http://wackowiki.com/"
  }

  def self.get_regexp_part
    "((http|ftp|https)://[+~'A-Za-z0-9_!=&?\\.\\-/%]+(,[+~'A-Za-z0-9_!=&?\\.\\-/%]+)*)"+
    "|"+
    "(www\\.[+~'A-Za-z0-9_!=&?\\.\\-/%]+(,[+~'A-Za-z0-9_!=&?\\.\\-/%]+)*)"+
    "|"+
    "((mailto:)?([A-Za-z\\.\\-_0-9]+)@([A-Za-z\\.\\-0-9]+\\.[A-Za-z]+))"+
    "|"+
    "([A-Za-z]+:\\S+)"+
    "|"+
    "(\\(\\?.*?\\?\\))"+
    "|"+
    "(\\(\\(.*?\\)\\))"+
    "|"+
    "(\\[\\[.*?\\]\\])"
  end

  def self.detect( outer_text )
    _m = @@re.match(outer_text)
    return false unless _m

    url = outer_text.dup
    text = outer_text.dup
    is_abbr = false

    matches = @@re_custom.match(outer_text)
    if matches
      is_abbr = true if matches[1] == "(?"
      contents = []
      if matches[3].index("==") == nil
        contents = matches[3].split(" ")
      else
        contents = matches[3].split("==")
      end
      url = contents[0].strip
      contents[0] = nil
      if matches[3].index("==") == nil
        text = contents.join(" ").strip
      else
        text = contents.join("==")[2..-1].strip
      end
      p text
    end

    result = OpenStruct.new({
      :content => text,
      :text => outer_text,
      :is_abbr => is_abbr
    }.merge(prepare_url(url)))

    result.content = outer_text.strip if result.content.empty?

    return result
  end

  def self.prepare_url( url )
    matches = @@re_interwiki.match(url)
    if matches
      lower = matches[1].downcase
      if @@interwiki[lower]
        return { :protocol => '', :url => @@interwiki[lower] + URI::escape(matches[2]) }
      end
    end
    result = { :url => url, :protocol => 'http://' }

    matches = @@re_protocol.match(url)
    if matches
      result[:protocol] = matches[0]
      result[:url] = result[:url][matches[0].length..-1]
    end

    if url.index("@") != nil
      result[:protocol] = "mailto:"
      result[:url].sub!(/^mailto:/, '')
    end

    return result
  end

  def compile
    if @data.is_abbr
      @html = "<dfn title=\"#{@data.content}\">#{@data.url}</dfn>"
    else
      @html = "<a #{@@open_in_new_window ? "target=\"_blank\" " : ""}href=\"#{@data.protocol}#{@data.url}\">#{@data.content}</a>"
    end
    # ignore for next pass of formatter
    @html = "<#{@wf.ignoreTagName}>#{@html}</#{@wf.ignoreTagName}>"
  end

  private

  @@re_protocol = /^(http|ftp|https):\/\//i
  #                  1        2
  @@re_interwiki = /^([a-z]+):(.+)$/i
  #               1      2            3    4      5
  @@re_custom = /^(\({2}|(\(\?)|\[{2})(.*?)(\){2}|(\?\))|\]{2})$/i

  @@re = /^(#{self.get_regexp_part})$/

end

end
