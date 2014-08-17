

describe 'util#truncate when ambiwidth = single'
  before
    set ambiwidth=single
  end
  " it 'returns 123456789 as ""'
  "   Expect thingspast#util#truncate('123456789', 0, '...') == ''
  " end
  it 'returns 123456789 as is'
    Expect thingspast#util#truncate('123456789', 9, '...') == '123456789'
  end
  it 'truncate 123456789 as 12345...'
    Expect thingspast#util#truncate('123456789', 8, '...') == '12345...'
  end
  it 'truncate multi-byte word'
    Expect thingspast#util#truncate('123456789', 9, '…') == '123456789'
  end
  it 'truncate multi-byte word'
    Expect thingspast#util#truncate('あ3456789', 9, '…') == 'あ3456789'
  end
  it 'truncate multi-byte word'
    Expect thingspast#util#truncate('あ3456789', 8, '…') == 'あ34567…'
  end
  it 'truncate multi-byte word'
    Expect thingspast#util#truncate('あいうえお', 10, '…') == 'あいうえお'
  end
  it 'truncate multi-byte word'
    Expect thingspast#util#truncate('あいうえお', 9, '…') == 'あいうえ…'
  end
  it 'truncate multi-byte word'
    Expect thingspast#util#truncate('あいうえお', 9, '>') == 'あいうえ>'
  end
end

describe 'util#truncate when ambiwidth = double'
  before
    set ambiwidth=double
  end
  " it 'returns 123456789 as ""'
  "   Expect thingspast#util#truncate('123456789', 0, '...') == ''
  " end
  it 'returns 123456789 as is'
    Expect thingspast#util#truncate('123456789', 9, '...') == '123456789'
  end
  it 'truncate 123456789 as 12345...'
    Expect thingspast#util#truncate('123456789', 8, '...') == '12345...'
  end
  it 'truncate multi-byte word'
    Expect thingspast#util#truncate('123456789', 9, '…') == '123456789'
  end
  it 'truncate multi-byte word'
    Expect thingspast#util#truncate('あ3456789', 9, '…') == 'あ3456789'
  end
  it 'truncate multi-byte word'
    Expect thingspast#util#truncate('あ3456789', 8, '…') == 'あ3456…'
  end
  it 'truncate multi-byte word'
    Expect thingspast#util#truncate('あいうえお', 10, '…') == 'あいうえお'
  end
  it 'truncate multi-byte word'
    Expect thingspast#util#truncate('あいうえお', 9, '…') == 'あいう …'
  end
  it 'truncate multi-byte word'
    Expect thingspast#util#truncate('あいうえお', 9, '>') == 'あいうえ>'
  end
end

describe 'util#combine_width'
  it 'should be "a b"'
    Expect thingspast#util#combine_width('a', 'b', 3) == 'a b'
  end
  it 'should be "a  b"'
    Expect thingspast#util#combine_width('a', 'b', 4) == 'a  b'
  end
  it 'should be "aaaaaaaaaa bbbbbbbbbb"'
    Expect thingspast#util#combine_width('aaaaaaaaaa', 'bbbbbbbbbb', 21) == 'aaaaaaaaaa bbbbbbbbbb'
  end
  it 'should be "aaaaaa... bbbbbbbbbb"'
    Expect thingspast#util#combine_width('aaaaaaaaaa', 'bbbbbbbbbb', 20) == 'aaaaaa... bbbbbbbbbb'
  end
end
