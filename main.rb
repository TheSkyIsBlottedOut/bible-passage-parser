=begin
  PassageParser, should match books of the bible
  This looked like a good page for abbreviations:
  # http://www.logos.com/support/windows/L3/book_abbreviations

  Also, should be able to match the following formats:

  Book ch
  Book c1-c2
  Book ch:vs
  Book ch:v1-v2
  Book ch:v1,v2,...,vn
=end


module PassageParser
  Ordinals = ['(?:1(?:st)*|I|First)', '(?:2(?:nd)|II|Second)', '(?:3(?:rd)|III|Third)']
  Books = {
    'Genesis'         => 'G(?:e|n|en)(?:esis)*',
    'Exodus'          => 'Ex(?:od*(?:us)*)*',
    'Leviticus'       => 'Le*v*(?:iticus)*',
    'Numbers'         => 'N(?:u|m|b|um|umbers)',
    'Deuteronomy'     => 'D(?:eu)*t(?:eronomy)*',
    'Joshua'          => 'Jo*sh*(?:ua)*',
    'Judges'          => 'Ju*d*ge*s*',
    'Ruth'            => 'R(?:u|th)',
    '1 Samuel'        => '#1 S(?:a|am|m)(?:uel)*',
    '2 Samuel'        => '#2 S(?:a|am|m)(?:uel)*',
    '1 Kings'         => '#1 Ki*n*g*s*',
    '2 Kings'         => '#2 Ki*n*g*s*',
    '1 Chronicles'    => '#1 Chr*(?:on(?:icles)*)*',
    '2 Chronicles'    => '#2 Chr*(?:on(?:icles)*)*',
    'Ezra'            => 'Ezra*',
    'Nehemiah'        => 'Neh*(?:emiah)*',
    'Esther'          => 'Es(?:th(?:er)*)*',
    'Job'             => 'Jo*b',
    'Psalms'          => 'Ps(?:a|m|ss|lm|alms*)*',
    'Proverbs'        => 'Pro*v*(?:erbs*)*',
    'Ecclesiastes'    => '(Ec(?:cles(?:iastes))|Qoh(?:eleth)*)',
    # what is a canticle? i guess it is a song, or a solomon
    'Song of Solomon' => '(?:S(?:OS|o(?:ngs*(?:\sof\sSo(?:ngs|lomon)*)*))|Canticle(?:s|\sof\sCanticles)*)',
    'Isaiah'          => 'Isa*(?:iah)*',
    'Jeremiah'        => 'J(?:e|r|er(?:emiah)*)',
    'Lamentations'    => 'Lam*(?:entations)*',
    'Ezekiel'         => 'Ez(?:e|k|ek(?:iel)*)',
    'Daniel'          => 'D(?:a|n|an(?:iel)*)',
    # all these people, why are you all writing the bible
    'Hosea'           => 'Hos*(?:ea)*',
    'Joel'            => 'J(?:l|oel*)',
    'Amos'            => 'Am(?:os)*',
    'Obadiah'         => 'Ob(?:ad(?:iah)*)*',
    'Jonah'           => 'J(?:nh|on|onah)',
    'Micah'           => 'Mic(?:ah)*',
    'Nahum'           => 'Na(?:h(?:um)*)*',
    'Habakkuk'        => 'Hab(?:akkuk)*',
    'Zephaniah'       => 'Ze*ph*(?:aniah)*',
    'Haggai'          => 'Ha*g(?:gai)*',
    'Zechariah'       => 'Ze*ch*(?:ariah)*',
    'Malachi'         => 'Ma*l(?:achi)*',
    # no i am not doing the catholic books, they are many
    # also there is a fourth maccabees
    'Matthew'         => 'Ma?tt?(?:hew)*',
    'Mark'            => 'Ma?(?:r|k|rk)',
    'Luke'            => 'Lu?ke?',
    # john also has to NOT match 1/2/3 john. This is sort of close enough
    'John'            => '(?<!1 |2 |3 )Jo?h?n',
    'Acts'            => 'Act?s?',
    'Romans'          => 'R(?:o|m|om)(?:ans)*',
    '1 Corinthians'   => '#1 Cor?(?:inthians)*',
    '2 Corinthians'   => '#2 Cor?(?:inthians)*',
    'Galatians'       => 'Gal?(?:atians)*',
    'Ephesians'       => 'Eph(?:es(?:ians)*)*',
    'Philippians'     => 'Ph(?:p|il(?:ippians)*)*',
    'Colossians'      => 'Col(?:ossians)*',
    '1 Thessalonians' => '#1 Th(?:ess?(?:alonians)*)*',
    '2 Thessalonians' => '#2 Th(?:ess?(?:alonians)*)*',
    '1 Timothy'       => '#1 Ti(?:m(?:othy)*)*',
    '2 Timothy'       => '#2 Ti(?:m(?:othy)*)*',
    'Titus'           => 'Tit(?:us)*',
    'Philemon'        => 'Ph(?:ile)*m(?:on)*',
    'Hebrews'         => 'Heb(?:rews)*',
    'James'           => 'J(?:as|m|ames)',
    '1 Peter'         => '#1 Pet?(?:er)*',
    '2 Peter'         => '#2 Pet?(?:er)*',
    '1 John'          => '#1 J(?:ohn|oh|hn|n|o)',
    '2 John'          => '#2 J(?:ohn|oh|hn|n|o)',
    '3 John'          => '#3 J(?:ohn|oh|hn|n|o)',
    'Jude'            => 'Jude?',
    'Revelation'      => 'Rev?(?:elation)*'
  }

  class << self
    def regexp(book)
      pattern = ?( + Books[book].sub(/\#(\d+)/) {|s| Ordinals[s[/\d/].to_i - 1]} + ?)
      pattern += '(?:\s+([\d\:\-]+))*'
      Regexp.new(pattern)
    end

    def book_order(passagetext)
      max = Books.length # 66
      Books.keys.reverse.each_with_index do |book, idx|
        match = passagetext.scan(regexp(book)).first
        next unless match
        puts match.inspect
        chapter = match[1].scan(/(\d+)\:/).first
        verse = match[1].scan(/\:(\d+)/).first
        chapter = chapter ? chapter.first.to_i : nil
        verse = verse ? verse.first.to_i : nil
        retval = {book: (max - idx), chapter: chapter, verse: verse}
        return retval
      end
      {book: nil, chapter: nil, verse: nil}
    end
  end
end
