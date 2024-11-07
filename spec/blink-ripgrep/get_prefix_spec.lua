local assert = require("luassert")
local blink_ripgrep = require("blink-ripgrep")

describe("match_prefix", function()
  it("for simple strings", function()
    assert.are_same(blink_ripgrep.match_prefix("hello"), "hello")
    assert.are_same(blink_ripgrep.match_prefix("abc123"), "abc123")
    assert.are_same(blink_ripgrep.match_prefix("abc-123"), "abc-123")
    assert.are_same(blink_ripgrep.match_prefix("abc_123"), "abc_123")
  end)

  it(
    "matches when there is one nonmatching piece of input in the beginning",
    function()
      assert.are_same(blink_ripgrep.match_prefix(".hello"), "hello")
      assert.are_same(blink_ripgrep.match_prefix(",hello"), "hello")
      assert.are_same(
        blink_ripgrep.match_prefix(".,,!@!@$@%<<@$<hello"),
        "hello"
      )
      assert.are_same(blink_ripgrep.match_prefix(" hello"), "hello")
      assert.are_same(blink_ripgrep.match_prefix("random_text hello"), "hello")
      assert.are_same(blink_ripgrep.match_prefix("-- hello"), "hello")
      assert.are_same(blink_ripgrep.match_prefix("-- abc123"), "abc123")
      assert.are_same(blink_ripgrep.match_prefix("-- abc-123"), "abc-123")
      assert.are_same(blink_ripgrep.match_prefix("-- abc_123"), "abc_123")
    end
  )

  it("matches when there is nonmatching input at the end", function()
    assert.are_same(blink_ripgrep.match_prefix(".hello)"), "hello")
    assert.are_same(blink_ripgrep.match_prefix(",hello)"), "hello")
    assert.are_same(
      blink_ripgrep.match_prefix(".,,!@!@$@%<<@$<hello)"),
      "hello"
    )
    assert.are_same(blink_ripgrep.match_prefix(" hello)"), "hello")
    assert.are_same(blink_ripgrep.match_prefix("random_text hello)"), "hello")
    assert.are_same(blink_ripgrep.match_prefix("-- hello)"), "hello")
    assert.are_same(blink_ripgrep.match_prefix("-- abc123)"), "abc123")
    assert.are_same(blink_ripgrep.match_prefix("-- abc-123)"), "abc-123")
    assert.are_same(blink_ripgrep.match_prefix("-- abc_123)"), "abc_123")
  end)

  it(
    "matches when there are multiple nonmatching pieces of input in the beginning",
    function()
      assert.are_same(blink_ripgrep.match_prefix(".hello.hello"), "hello")
      assert.are_same(blink_ripgrep.match_prefix(",hello,hello"), "hello")
      assert.are_same(
        blink_ripgrep.match_prefix(".,,!@!@$@%<<@$<hello.,,!@!@$@%<<@$<hello"),
        "hello"
      )
      assert.are_same(blink_ripgrep.match_prefix(" hello hello"), "hello")

      assert.are_same(
        blink_ripgrep.match_prefix("random_text hello hello"),
        "hello"
      )
      assert.are_same(blink_ripgrep.match_prefix("-- hello hello"), "hello")
      assert.are_same(blink_ripgrep.match_prefix("-- abc123 abc123"), "abc123")
      assert.are_same(
        blink_ripgrep.match_prefix("-- abc-123 abc-123"),
        "abc-123"
      )
      assert.are_same(
        blink_ripgrep.match_prefix("-- abc_123 abc_123"),
        "abc_123"
      )
    end
  )

  it("for multipart strings", function()
    -- three parts
    assert.are_same(
      blink_ripgrep.match_prefix("hello-world-today"),
      "hello-world-today"
    )

    -- three parts with numbers
    assert.are_same(
      blink_ripgrep.match_prefix("abc123-def456-ghi789"),
      "abc123-def456-ghi789"
    )

    -- multiple parts with mixed dashes and underscores
    assert.are_same(
      blink_ripgrep.match_prefix("abc-123_def-456_ghi-789"),
      "abc-123_def-456_ghi-789"
    )
  end)

  it("matches special characters", function()
    -- umlauts and other special characters
    assert.are_same(blink_ripgrep.match_prefix("yöllä"), "yöllä") -- Finnish word with 'ö' and 'ä'
    assert.are_same(blink_ripgrep.match_prefix("über"), "über") -- German word with 'ü'
    assert.are_same(blink_ripgrep.match_prefix("übermensch"), "übermensch") -- German compound word with 'ü'
    assert.are_same(blink_ripgrep.match_prefix("mañana"), "mañana") -- Spanish word with 'ñ'
    assert.are_same(blink_ripgrep.match_prefix("Ångström"), "Ångström") -- Swedish word with 'Å' and 'ö'
    assert.are_same(blink_ripgrep.match_prefix("Straße"), "Straße") -- German word with 'ß'
    assert.are_same(blink_ripgrep.match_prefix("český"), "český") -- Czech word with 'č'
    assert.are_same(blink_ripgrep.match_prefix("naïve"), "naïve") -- French word with 'ï'
    assert.are_same(blink_ripgrep.match_prefix("façade"), "façade") -- French word with 'ç'
    assert.are_same(blink_ripgrep.match_prefix("résumé"), "résumé") -- French word with 'é'
    assert.are_same(blink_ripgrep.match_prefix("космос"), "космос") -- Russian word with Cyrillic characters
    assert.are_same(blink_ripgrep.match_prefix("你好"), "你好") -- Chinese characters
    assert.are_same(blink_ripgrep.match_prefix("日本語"), "日本語") -- Japanese characters
    assert.are_same(blink_ripgrep.match_prefix("한국어"), "한국어") -- Korean characters
    assert.are_same(blink_ripgrep.match_prefix("τοπική"), "τοπική") -- Greek word with 'π' and 'ή'
  end)

  it("matches emoji", function()
    -- because why not 😄
    assert.are_same(blink_ripgrep.match_prefix("👍👎"), "👍👎")
    assert.are_same(blink_ripgrep.match_prefix("👍-👎"), "👍-👎")
  end)

  it("does not include punctuation characters", function()
    assert.are_same(blink_ripgrep.match_prefix("!hello"), "hello")
    assert.are_same(blink_ripgrep.match_prefix("?world"), "world")
    assert.are_same(blink_ripgrep.match_prefix("#hashtag"), "hashtag")
    assert.are_same(blink_ripgrep.match_prefix("$money"), "money")
    assert.are_same(blink_ripgrep.match_prefix("%value"), "value")
    assert.are_same(blink_ripgrep.match_prefix("&and"), "and")
    assert.are_same(blink_ripgrep.match_prefix("*star"), "star")
    assert.are_same(blink_ripgrep.match_prefix("@email"), "email")
    assert.are_same(blink_ripgrep.match_prefix("~tilde"), "tilde")
    assert.are_same(blink_ripgrep.match_prefix(";semicolon"), "semicolon")
    assert.are_same(blink_ripgrep.match_prefix(":colon"), "colon")
  end)

  it("does not include whitespace and control characters", function()
    assert.are_same(blink_ripgrep.match_prefix(" hello"), "hello")
    assert.are_same(blink_ripgrep.match_prefix("world "), "world")
    assert.are_same(blink_ripgrep.match_prefix("\t\ttext"), "text")
    assert.are_same(blink_ripgrep.match_prefix("\nnewline"), "newline")
  end)

  it("includes symbols", function()
    assert.are_same(blink_ripgrep.match_prefix("©copyright"), "©copyright")
    assert.are_same(blink_ripgrep.match_prefix("®registered"), "®registered")
    assert.are_same(blink_ripgrep.match_prefix("™trademark"), "™trademark")
  end)
end)
