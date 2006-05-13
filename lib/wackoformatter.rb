require 'ostruct'
require 'wacko/token'
require 'wacko/empty'
require 'wacko/decoration'
require 'wacko/decoration_word'
require 'wacko/decoration_glue'
require 'wacko/decoration_headers'
require 'wacko/links'
require 'wacko/ignore'
require 'wacko/symbols'
require 'wacko/email_quotes'
require 'wacko/lists'


class WackoFormatter
  # prebuild regexp for all presets
  def initialize
    @@presets.each do |key, preset|
      regex = []
      preset[:list].each do |klass|
        regex << get_class(klass).get_regexp_part
      end if preset[:list]
      @@presets[key][:re] = Regexp.new(regex.join("|")) unless regex.empty?
    end
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
        elsif preset == :return_ignored
          what = what.split(@@ignoreChar, -1).zip(ignored).to_s
        else
          what = to_html( what, preset )
        end
      end

      return what;
    else
      return to_html(what, @@defaultPreset) unless @@presets[presets]
    end

    tree = build_tree(what, presets)
    return format_tree(tree)
  end

  # Build tree of tokens for further compilation.
  # Could be built, then analyzed.
  def build_tree( what, preset )
    what.gsub!(/\r/, '')
    preset = :default unless @@presets[preset]

    # 1. get all matches.
    matches = all_matches(@@presets[preset][:re], what)

    # 2. step by step check`n`build
    tree = []
    token = false
    token_list = []

    matches.each do |match|
      unless match.fake
        if match.plain
          token = get_class(@@presets[preset][:empty]).new
          token.bind self
          token.set_next_preset @@presets[preset][:next]
          token_list = token.build(match.match, tree.last)
          token_list.each do |tok|
            tree << tok
          end
        else
          no_match = true
          @@presets[preset][:list].each do |item|
            struct = get_class(item).detect(match.match)
            if struct
              token = get_class(item).new
              token.bind self
              token.set_next_preset @@presets[preset][:next]
              token_list = token.build(struct, tree.last)
              token_list.each do |tok|
                tree << tok
              end
              no_match = false
              break
            end
          end
          if no_match # same as plain, welcome copypaster!
            token = get_class(@@presets[preset][:empty]).new
            token.bind self
            token.set_next_preset @@presets[preset][:next]
            token_list = token.build(match.match, tree.last)
            token_list.each do |tok|
              tree << tok
            end
          end
        end
      end
    end

    tree
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

#  cattr_accessor :css_prefix
  @@css_prefix = "wiki-"

  def self.css_prefix
    @@css_prefix
  end

  def css_prefix
    @@css_prefix
  end

  def self.css_prefix=( prefix )
    @@css_prefix = prefix
  end

  def css_prefix=( prefix )
    @@css_prefix = prefix
  end

#  cattr_accessor :css_suffix
  @@css_suffix = ""

  def self.css_suffix
    @@css_suffix
  end

  def css_suffix
    @@css_suffix
  end

  def self.css_suffix=( suffix )
    @@css_suffix = suffix
  end

  def css_suffix=( suffix )
    @@css_suffix = suffix
  end


  @@defaultPreset = [ :links, :skip_ignored, :default, :return_ignored ]
  @@presets = {
    :links => {
      :list => [ "Links", "Ignore" ],
      :empty => "Token",
      :next => false
    },
    :default => { # Main cycle
      :list => [ "Decoration", "DecorationWord", "DecorationGlue", "DecorationHeaders", "Lists", "EmailQuotes" ],
      :empty => "Token",
      :next => :symbols
    },
    :symbols => { # Very simple, but sometimes useful one
      :list => [ "Symbols" ],
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

  def ignoreTagName
    @@ignoreTagName
  end

  private

  # returns all matches of "re" in a given "what".
  @@allMatchesSpecialChar = "\xA3"  # used to avoid treating end-of-match as start-of-text for next match

  def all_matches( re, what )
    matches = []
    m = true

    matches << OpenStruct.new({
      :match => "!fake!",
      :start => 0,
      :end   => 0,
      :fake  => true
    })

    while m
      if matches.size == 1
        m = what.match(re)
      else
        m = (@@allMatchesSpecialChar + what).match(re)
      end

      if m
        pos = what.index(m[0])

        if pos > 0
          matches << OpenStruct.new({
            :match => what[0, pos],
            :start => matches.last.end,
            :end   => matches.last.end + pos,
            :plain => true
          })
        end

        matches << OpenStruct.new({
          :match => m[0],
          :start => matches.last.end,
          :end   => matches.last.end + m[0].length
        })

        what = what[pos + m[0].length..-1]
      end
    end

    if what.length > 0
      matches << OpenStruct.new({
        :match => what,
        :start => matches.last.end,
        :end   => matches.last.end + what.length,
        :plain => true
      })
    end

    matches
  end

  def get_class(name)
    ["WookieFormat", name].inject(Object) { |o, sub| o.const_get(sub) }
  end
end
