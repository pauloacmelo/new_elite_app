# encoding: UTF-8

require 'find'

this_path = File.dirname(File.expand_path(__FILE__))

# parameters = '0.4 60 540 80 40 2900 4229 2 1245 6 0123456789 79 38 304 795 1003 300 2 705 50 ABCDE 77 38 846 1185 486 2659'
parameters = '0.4 60 540 80 40 2900 4229 1 0 6 0123456789 79 38 304 795 1003 300 2 705 50 ABCDE 77 38 846 1185 486 2659 1 0 5 0123456789 79 38 1550 815 1010 250'
folder_path = '/Users/pauloacmelo/Downloads/CardsC/' # TOFILL
# folder_path = '/Users/pauloacmelo/Downloads/Teste5/' # TOFILL
file_to_be_processed_format = '.tif'

  def is_valid_result(result)
  result.split('').uniq.each do |c|
    unless %w[A B C D E W Z 0 1 2 3 4 5 6 7 8 9].include? c
      return false
    end
  end
  true
end

print "=> Compiling card scanner\n"
p "ruby '#{this_path}/../compile.rb'"
`ruby '#{this_path}/../compile.rb'`

print "=> Removing old files\n"
`find '#{folder_path}' -name '*.png' -exec rm '{}' \\;`

print "=> Converting to tif\n"
`find '#{folder_path}' -name '*.tif' -exec convert '{}' '{}' \\;`

print "=> Scanning cards\n"
lines = []

Find.find(folder_path) do |file_path|
  p file_path
  next if File.extname(file_path) != file_to_be_processed_format

  normalized_path = File.join(File.dirname(file_path), 
    File.basename(file_path, file_to_be_processed_format) + '_normalized.png')

  p "'#{this_path}/../bin/run' '#{file_path}' '#{normalized_path}' #{parameters}"
  result = `'#{this_path}/../bin/run' '#{file_path}' '#{normalized_path}' #{parameters}`
  p result

  if is_valid_result(result) 
    lines << 'Valid;' + file_path + ';' + result + "\n"
  else
    lines << 'Error;' + file_path + ';' + "\n"
  end
end

filename = File.basename(folder_path).gsub(/\s+/,'_')
File.open("#{folder_path}/../scanner_result_#{filename}.csv", 'w') do |f2| 
  lines.each do |line|
    f2.puts line
  end
end 

`iconv -f utf-8 -t windows-1252 "#{folder_path}/../scanner_result_#{filename}.csv" > "#{folder_path}/../scanner_result_#{filename}_ansi.csv"`