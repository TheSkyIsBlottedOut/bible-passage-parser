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
  Ordinals = ['(?:1(?:st)*|I|First)', '(?:2(?:nd)*|II|Second)', '(?:3(?:rd)*|III|Third)']
  Books = {
    'Genesis'         => 'G(?:e|n|en)(?:esis)*',
    'Exodus'          => 'Ex(?:od*(?:us)*)*',
    'Leviticus'       => 'Le*v*(?:iticus)*',
    'Numbers'         => 'N(?:u|m|b|um|umbers)',
    'Deuteronomy'     => 'D(?:eu)*t(?:eronomy)*',
    'Joshua'          => 'Jo*sh*(?:ua)*',
    'Judges'          => 'Ju*d*ge*s*',
    'Ruth'            => 'R(?:u|th|uth)*',
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
    'Psalms'          => 'Ps(?:alms*|lm|a|m|ss)*',
    'Proverbs'        => 'Pro*v*(?:erbs*)*',
    'Ecclesiastes'    => '(?:Ec(?:cles(?:iastes))?|Qoh(?:eleth)*)',
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
      pattern += '\b(?:\s+([\d\:\-]+))*'
      Regexp.new(pattern)
    end

    def book_order(passagetext)
      text = passagetext.to_s.gsub(/\d+/) {|n| n.rjust(3,?0)}
      max = Books.length # 66
      retval = {book: nil, chapter: nil, verse: nil}
      return retval if text.empty?
      Books.keys.reverse.each_with_index do |book, idx|
        match = regexp(book).match(text)
        next unless match
        cv = match[2].to_s
        chapter = cv.split(?:).first.to_s.scan(/\d+/).first.to_i
        verse = cv.scan(/\:(\d+)/).first
        chapter = (chapter > 0) ? chapter.to_i.to_s.rjust(3,?0) : nil
        verse = verse ? verse.first.to_i.to_s.rjust(3, ?0) : nil
        retval = {book: (max - idx).to_s.rjust(2, ?0), chapter: chapter, verse: verse, match: match[0]}
        return retval
      end
      retval
    end

    def select_options
      Books.keys.map {|x| [x, x.tokenize]}
    end

    def book_for_token(t)
      Books.keys.select {|x| x.tokenize == t}.first
    end

    def order_for_token(t)
      match = Books.keys.each_with_index.select {|x,i| x.tokenize == t}.first
      match ? match.last : nil
    end
  end
end
