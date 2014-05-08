# encoding: UTF-8

require 'find'

this_path = File.dirname(File.expand_path(__FILE__))

# parameters = '0.4 60 540 80 40 2900 4229 2 1245 6 0123456789 79 38 304 795 1003 300 2 705 50 ABCDE 77 38 846 1185 486 2659'
# parameters = '0.4 60 540 80 40 2900 4229 1 0 6 0123456789 79 38 304 795 1003 300 2 685 50 ABCDE 77 38 846 1185 486 2659 1 0 5 0123456789 79 38 1528 809 978 250'
parameters = '0.4 60 540 80 40 2900 4229 1 0 6 0123456789 79 38 320 785 975 300 2 675 50 ABCDE 77 38 846 1185 475 2659 1 0 5 0123456789 79 38 1526 815 975 250'
folder_path = '/Users/pauloacmelo/Downloads/TestElite/' # TOFILL
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

should_be_answers = {
  228849 => "07976150001ADBEAEBEBBDACBABECADCAEBDCEDDBABBACDDDDDDCAEDDDDEBDCBBADADDDEEABEDCEDDEBAADACACBDBCCABAAECZZZZZZZZZZ",
  228855 => "11376950001EEAEEBBEDBDDBCAABAADEDBBDCEDACACBEACCBDCAECABCCEEDDACBEDADEAECAEDDBDEEDEDDEDEBDDCDDZEDCADDZZZZZZZZZZ",
  228870 => "07226650001AECDEABDDDCBEDDBDCCBCDEDDCECACACBDCCBBCEACADDDDEABBDBACBADCCABBBDEBACEEBACAEAACDCBCDADABEDZZZZZZZZZZ",
  228892 => "10877350001EECAEABBDECDEACCCCACCDBCDDECACAEDBDEBBDAAEAEADDBABCABACAACCBACEBBDCEDDEBBAEAECABDCADADAABEZZZZZZZZZZ",
  228935 => "08923750001EEBAACADEECBACBBECACACACDCECBDAEEEDABEDEEEADCDDEAEEDBDCEDEDDBEABBDAEDDBBAADEAAACCBCCBBAABDZZZZZZZZZZ",
  228946 => "08563850001DEBDEBAECCBBEEECCCABCDADDCEDEBAEDBEBDEDCEDAACDCEEADECDCDDEAECEDBCDDADEEBECDEDECCBBCCAABBDCZZZZZZZZZZ",
  228948 => "03403250001EEDDABBACCCDEBAACDBDACEACAABBDDEABCDAEECDBACBDDEAZADDEBBACEBACDEEAACADECBBADBCAEDDCAABEDDCZZZZZZZZZZ",
  229169 => "10134150001CECDBBBCACEBEDBCBBAEDDBCDCECACADDACCACDBECADBDDDABBBDDCDCCABCAABADAEBCBDABCADBECADAEACBDEAZZZZZZZZZZ",
  229171 => "10890750001CCDDECABDBCAEDBCEEACAABDDADCDCABEDDAEEAECCADBDDCACBAEAEBBCECCEAEBBDDAEDDDACABABBBECACBAAEEZZZZZZZZZZ",
  229176 => "10Z6Z850001AEEDAEADDBDBCAECBAACCABBDAEBEAADCECBBCDADEEBCDCBAAEBEAEEDCBABDABDCADACDEAEBABDACADCBDEADCCZZZZZZZZZZ",
  229200 => "10104850001EECBECAADCADBACCEEAEABBDDACBCAAEDBEACBAEDBADCAECCCBDBAEBBDCAECADBECCBAEDDAAEDABBEDAECBAAEEZZZZZZZZZZ",
  229881 => "06617350001AECDCBBDDECBCBAACCADADBEDCECADAEECDEBBDAEEEECDDEABEDBACCAEEBECABDDCEEDEBEACEAABBDBCBAEAAAEZZZZZZZZZZ",
  229931 => "10758450001AEBDEBADDADBCDCBDCADACAEDDECABAEDCAEBEDAECACCDCEAEDBBABBCDABEABABEAAABBBAEDAABDBDDEBCDABEBZZZZZZZZZZ",
  229969 => "10325750001AEADEABEDCDBECACDCABCDEBDCECECCCEABDAAABECADCDCBCCCBBEBACDCDEBECABBDCBDAADCEABECEBACDDBABDZZZZZZZZZZ",
  229975 => "10138350001AECBEEBDDCDBCCABCDBDZEBBDCEADAABDCAEDEACECDDEDEBACDDBBBACDADECBBDDDADDEBACDDEAAEDACCADAABEZZZZZZZZZZ",
  229980 => "10148750001EECDEEAADBABCCAAECADADCBDAEBABACECDBEBDCDCBAEDDEABCBBBDBCBDEAEDEDBCABECDCDDEECABDBCCEEAABCZZZZZZZZZZ",
  229982 => "10138850001CEBDEBBDDBDBECEBACACCDBDDAECDCAEDDDBBBCAECAECZZZZZCABBCBAAEEECDEBACDDEEBABDADBEEDDBACEABACZZZZZZZZZZ",
  230000 => "ZZZZZZ50001ABCDADADCECBECBACCABADBBDCEDADACEAEABEDCACCADDDAADBBEACEAEAEACAADDAEAECAACEADDBDBAACDCABEBZZZZZZZZZZ",
  230003 => "10361450001CECDABCBDEDAEEBDCCABDDBEDAEADCABDCDEDBAABCABCBCECAADEWAEEECECABCECDCZAABADBEDDACBEBBCAEACDZZZZZZZZZZ",
  230005 => "05709050001AECDECBEAEDBECAAEEADADECDCECABAAECECCEAEAABCECCECEBABCDCEAEDBAEEDACEDEACCDCAACDEDBACDDCAADZZZZZZZZZZ",
  230214 => "10721501001ABCDEABDABDBCECDECADCAEDDCECABAEBCECCEDEAECEBEDEAACCEECBCEBEECABAECEBAEDAEDEADCEACCAEAAABCZZZZZZZZZZ",
  230246 => "10997701001ACCAEEEADDDBCCDEBEADEDBCDDAABEADBECECEBDEADCABWAADBADACBECCCACBDADCDAEBCEDBCADACAAADEBAADEZZZZZZZZZZ",
  230314 => "10052701001AECDEBEDDBDBEBABCCAZZZZZZZZZZZZZZZZZZZZZZZZZZDDEACZZBEZZZECZZEZZZZCZZDZBZZZDDZZZZZZZAZZZZZZZZZZZZZZZ",
  230366 => "10978801001AECDCEAEDEDAAEBABAABCCEDDAEAACEEDBAEAECCAECEBDCAABCEEDBBCDAECDEBACBEAEDCDECAACDBECEBBAAAEEZZZZZZZZZZ",
  230370 => "10171001001CEBBABABCCAECDEAECADCBEBDCEEACCEEDBCCDAAECACDEBCEDBCEECCDEDBCBCDBEACADCBACBDABCDACEBDCBAEDZZZZZZZZZZ",
  252744 => "ZZZZZZ18025BABDBEEDCDZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ",
  266687 => "109031ZZZZZBBCABBBBDZZZZWWBDCEABAEDECDZBADECAEDBEABZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ",
  266697 => "ZZZZZZZZZZZBDABBCEDDEBABDCECBZBECBAEDCBABCECBECEDZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ"
}

debug = true
Find.find(folder_path) do |file_path|
  next if File.extname(file_path) != file_to_be_processed_format
  id = File.basename(file_path, ".tif").to_i
  next if debug && !should_be_answers.keys.include?(id)

  normalized_path = File.join(File.dirname(file_path), 
    File.basename(file_path, file_to_be_processed_format) + '_normalized.png')

  result = `'#{this_path}/../bin/run' '#{file_path}' '#{normalized_path}' #{parameters}`
  # p result if debug
  result = result.split("\n")[-1] #[11..110]

  if result == should_be_answers[id]
    p "#{id}: OK!"
  else
    p "#{id}: Error (#{result})"
    p "#{id}: Error (#{should_be_answers[id]})"
  end
end
