module WookieFormat

class Token
  attr_accessor :data

  def self.get_regexp_part
    ""
  end

  # bind token to instance of WackoFormatter
  def bind( inst )
    @wf = inst
  end

  def self.detect( outer_text )
    false
  end

  def set_next_preset( preset )
    @next_preset = preset
  end

  def parse( outer_text )
    build( detect( outer_text ) )
  end

  def build( data_struct, previous_token )
    return if data_struct == false

    @compiled = false
    @data = data_struct
    @prev = previous_token
    @parent = false
    @tree = []

    # this hack is used in some sophisticated tokens
    # to get rid of unnecessary newlines
    if (previous_token && previous_token.separate_trim_next_newline && @data.respond_to?("gsub!".to_sym))
      @data.gsub!( /^\n/, "" )
    end

    return false if glue
    return flatten_tree
  end

  # private abstract: preprocess tree after build
  # should be overriden to process subtree and gluein it in main parsing sequence
  def flatten_tree
    [self]
  end

  # private: glue to a previous token
  # returns true, if this token was glued up to parent one
  def glue
    false
  end

  # glues given token as child. returns true on success
  def glue_child( token_child )
    if @tree.size > 0
      token_child.prev = @tree.last
    else
      token_child.prev = false
    end

    if !token_child.glue
      token_child.parent = self
      @tree << token_child
    end

    true
  end

  # private: compile from struct to html
  def compile
    if @next_preset
      @html = @wf.to_html(@data, @next_preset)
    else
      @html = @data
    end

    @compiled = true
  end

  # returns separation from a given "next"
  def separate_from_next( nxt )
    ""
  end

  # this hack is used in some sophisticated tokens
  # to get rid of unnecessary newlines (see build above)
  def separate_trim_next_newline
    false
  end

  # pretty clear: returns HTML appearance of this token (and its children)
  def to_html
    sep = ""
    sep = @prev.separate_from_next(self) if @prev

    compile if !@compiled

    sep + @html
  end

  # special functionality for export content
  def to_text
    return @data.text if @data.responds_to?(:text)
    return @data
  end

end

end
