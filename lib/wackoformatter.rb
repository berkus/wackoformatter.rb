DEBUG = true

require 'wacko/token'
require 'wacko/empty'
require 'wacko/decoration_headers'

# instantiating an object down the tree with const_get
# <bitsweat> str.split('::').inject(Object) { |o, sub| o.const_get(sub) }.new
# my version would be (with hierarchy)
# ["WackoFormatterNS", classname].inject(Object) { |o, sub| o.const_get(sub) }.new


class WackoFormatter

  @@css_prefix = "wiki-"
  @@css_suffix = ""

  @@defaultPreset = [ :skip_ignored, :default, :return_ignored ]
  @@presets = {
    :default => { # Main cycle
      :list => [ "DecorationHeaders" ],
      :empty => "Token",
      :next => false
    },
    :skip_ignored => {
      :is_system => true
    },
    :return_ignored => {
      :is_system => true
    }
  }

  # stuff for ignoring
  @@ignoreTagName = "waka31ignore"
  @@ignoreRE = /<#{@@ignoreTagName}>((.|\n)*?)<\/#{@@ignoreTagName}>/
  @@ignoreChar = "\xA2"
  # \xA3 is also used below.


  # prebuild regexp for all presets
  def initialize
    @@presets.each do |key, preset|
      regex = []
      preset[:list].each do |klass|
        regex << Object.const_get(klass).get_regexp_part
      end if preset[:list]
      @@presets[key][:re] = Regexp.new(regex.join("|")) unless regex.empty?
    end
    p @@presets if DEBUG
  end

  # Convert markup to HTML, main entry point, USE THIS ONE.
  def to_html( what, presets = nil )
    presets = @@defaultPreset if presets.nil?

    ignored = [] # method-wide var

    if presets.is_a? Array
      presets.each do |preset|
        if preset == :skip_ignored
          ignored = []
          while m = @@ignoreRE.match( what )
            ignored << m[1]
            what[@@ignoreRE] = @@ignoreChar
          end
          p ignored if DEBUG
          p what if DEBUG
        elsif preset == :return_ignored
          what = what.split(@@ignoreChar).zip(ignored).to_s
          p what if DEBUG
        else
          what = to_html( what, preset )
        end
      end

      return what;
    else
      return to_html( what, @@defaultPreset ) unless @@presets[presets]
    end

    tree = build_tree( what, presets )
    return format_tree( tree )
  end

  # Build tree of tokens for further compilation.
  # Could be built, then analyzed.
  def build_tree( what, preset )
    what.gsub!(/\r/, '')
    preset = :default unless @@presets[preset]
  end

  def format_tree( tree )
    result = ""
    last = false
    tree.each do |leaf|
      result += leaf.to_html
      last = leaf
    end
    result += last.separate_from_next( false ) if last
    result
  end
end
