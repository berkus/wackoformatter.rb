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
      :empty => :token,
      :next => false
    },
    :skip_ignored => {
      :is_system => true
    },
    :return_ignored => {
      :is_system => true
    }
  }

  def initialize
    regex = []
    @@presets.values.each do |preset|
      preset[:list].each do |klass|
        regex << Object.const_get(klass).get_regexp_part
      end if preset[:list]
    end
    raise "No match regexps!" if regex.empty?
    @@regexp = Regexp.new(regex.join("|"))
  end

  def to_html
  end
end
