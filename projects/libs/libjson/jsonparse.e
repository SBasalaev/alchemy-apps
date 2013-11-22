use "json"
use "textio"
use "error"
use "lexer"
use "string"
use "math"

def jsonParseValue(lexer: Lexer): JsonValue {
  var tt = lexer.next()
  switch (tt) {
    TT_INT, TT_FLOAT: {
      new JsonNumber(lexer.value().todouble())
    }
    '"': {
      new JsonString(lexer.value())
    }
    TT_WORD: {
      var word = lexer.value()
      if (word == "null") {
        new JsonNull()
      } else if (word == "true") {
        new JsonBool(true)
      } else if (word == "false") {
        new JsonBool(false)
      } else if (word == "NaN") {
        new JsonNumber(NaN)
      } else if (word == "Infinity") {
        new JsonNumber(POS_INFTY)
      } else {
        error(ERR_ILL_ARG, "<jsoninput>:" + lexer.lineNumber() +": Unexpected token \"" + word + '"')
        null
      }
    }
    '-': {
      var val = jsonParseValue(lexer)
      if (val.getType() != JSON_NUMBER) {
        error(ERR_ILL_ARG, "<jsoninput>:" + lexer.lineNumber() + ": number expected after '-'")
      }
      new JsonNumber(-val.cast(JsonNumber).getValue())
    }
    '{': {
      var obj = new JsonObject()
      tt = lexer.next()
      var first = true
      while (tt != TT_EOF && tt != '}') {
        if (first) {
          first = false
        } else {
          if (tt != ',') {
            error(ERR_ILL_ARG, "<jsoninput>:" + lexer.lineNumber() +": ',' or '}' expected, got " + lexer.value())
          }
          tt = lexer.next()
        }
        if (tt != '"') {
          error(ERR_ILL_ARG, "<jsoninput>:" + lexer.lineNumber() +": string expected, got " + lexer.value())
        }
        var key = lexer.value()
        if (lexer.next() != ':') {
          error(ERR_ILL_ARG, "<jsoninput>:" + lexer.lineNumber() +": ':' expected, got " + lexer.value())
        }
        obj.set(key, jsonParseValue(lexer))
        tt = lexer.next()
      }
      obj
    }
    '[': {
      var array = new JsonArray()
      tt = lexer.next()
      var first = true
      while (tt != TT_EOF && tt != ']') {
        if (first) {
          first = false
          lexer.pushBack()
        } else {
          if (tt != ',') {
            error(ERR_ILL_ARG, "<jsoninput>:" + lexer.lineNumber() +": ',' or ']' expected, got " + lexer.value())
          }
        }
        array.add(jsonParseValue(lexer))
        tt = lexer.next()
      }
      array
    }
    else: {
      error(ERR_ILL_ARG, "<jsoninput>:" + lexer.lineNumber() +": Unexpected token \"" + jsonEscape(lexer.value()) + '"')
      null
    }
  }
}

def jsonParse(r: Reader): JsonValue {
  var lexer = new Lexer(r, PARSE_DECIMAL | PARSE_SLASHSTAR_COMMENTS)
  jsonParseValue(lexer)
}

type StringReader {
  str: String,
  pos: Int
}

def StringReader.read(ignored: IStream): Int {
  if (this.pos == this.str.len()) {
    -1
  } else {
    var ch = this.str[this.pos]
    this.pos += 1
    ch
  }
}

def jsonParseString(str: String): JsonValue {
  var sr = new StringReader(str, 0)
  jsonParse(new Reader(null, sr.read))
}
