# short for escape_snippet - escapes special snippet characters in str
def es(str)
  str.to_s.gsub(/([$`\\])/, "\\\\\\1")
end