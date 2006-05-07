# Empty token.
# Used for skipping whitespace in some formatting presets such as table.

module WookieFormat

class Empty < Token
  # always say it is glued up
  def glue
    true
  end

  # never returns html
  def compile
    ""
  end
end

end
