# bible-passage-parser
Finds bible passage references in text


Usage:

```
require 'passage.rb'
PassageParser.book_order 'Rev 1:26'

#=> {:book=>"66", :chapter=>"001", :verse=>"026", :match=>"Rev 001:026"}
```
