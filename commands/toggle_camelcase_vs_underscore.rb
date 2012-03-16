require 'ruble'

# Test Cases
# 
# AFooBar -> a_foo_bar -> aFooBar -> AFooBar
# URLString -> url_string -> urlString -> UrlString
# TestURLString -> test_url_string -> testUrlString -> TestUrlString
# test -> Test -> test
# test_URL_STRING -> testUrlString -> TestUrlString -> test_url_string


# HotFlamingCats -> hot_flaming_cats
def pascalcase_to_snakecase(word)
  word.gsub(/\B([A-Z])(?=[a-z0-9])|([a-z0-9])([A-Z])/, '\2_\+').downcase
end

# hot_flaming_cats -> hotFlamingCats
def snakecase_to_camelcase(word)
  word.gsub(/_([^_]+)/) { $1.capitalize }
end

# hotFlamingCats -> HotFlamingCats
def camelcase_to_pascalcase(word)
  word.gsub(/^\w{1}/) {|c| c.upcase}
end

command t(:toggle_case) do |cmd|
  cmd.key_binding = 'CONTROL+M2+-'
  cmd.scope = 'source'
  cmd.output = :replace_selection
  cmd.input = :selection, :word
  cmd.invoke do |context|
    word = $stdin.gets
    context.exit_discard if word.nil?
    
    is_pascal = word.match(/^[A-Z]{1}/) ? true : false
    is_snake = word.match(/_/) ? true : false
    
    if is_pascal then
    	print pascalcase_to_snakecase(word)
    elsif is_snake then
    	print snakecase_to_camelcase(word)
    else
    	print camelcase_to_pascalcase(word) 
    end
  end
end
