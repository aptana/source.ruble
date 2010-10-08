def find_markers
  10.times do |n|
    start = ENV["TM_COMMENT_START#{"_#{n}" if n > 0}"].to_s.strip
    stop  = ENV["TM_COMMENT_END#{"_#{n}"   if n > 0}"].to_s.strip
    return start, stop if not start.empty? and not stop.empty?
  end
  return [nil, nil]
end