use "strbuf"
use "dict"
use "list"

const JSON_NULL = 0
const JSON_STRING = 1
const JSON_NUMBER = 2
const JSON_BOOL = 3
const JSON_ARRAY = 4
const JSON_OBJECT = 5

type JsonValue {
  jsType: Int
}

def JsonValue.new(jstype: Int) {
  this.jsType = jstype
}

def JsonValue.getType(): Int {
  this.jsType
}

type JsonNull < JsonValue { }

def JsonNull.new() {
  super(JSON_NULL)
}

type JsonString < JsonValue {
  jsString: String
}

def JsonString.new(val: String) {
  super(JSON_STRING)
  this.jsString = val
}

def JsonString.getValue(): String {
  this.jsString
}

type JsonNumber < JsonValue {
  jsNumber: Double
}

def JsonNumber.new(val: Double) {
  super(JSON_NUMBER)
  this.jsNumber = val
}

def JsonNumber.getValue(): Double {
  this.jsNumber
}

type JsonBool < JsonValue {
  jsBool: Bool
}

def JsonBool.new(val: Bool) {
  super(JSON_BOOL)
  this.jsBool = val
}

def JsonBool.getValue(): Bool {
  this.jsBool
}

type JsonArray < JsonValue {
  jsList: List
}

def JsonArray.new() {
  super(JSON_ARRAY)
  this.jsList = new List()
}

def JsonArray.len(): Int {
  this.jsList.len()
}

def JsonArray.get(index: Int): JsonValue {
  this.jsList.get(index).cast(JsonValue)
}

def JsonArray.set(index: Int, val: JsonValue) {
  this.jsList.set(index, val)
}

def JsonArray.insert(index: Int, val: JsonValue) {
  this.jsList.insert(index, val)
}

def JsonArray.add(val: JsonValue) {
  this.jsList.add(val)
}

def JsonArray.toarray(): [JsonValue] {
  var array = new [JsonValue](this.jsList.len())
  this.jsList.copyinto(0, array, 0, array.len)
  array
}

type JsonObject < JsonValue {
  jsDict: Dict
}

def JsonObject.new() {
  super(JSON_OBJECT)
  this.jsDict = new Dict()
}

def JsonObject.len(): Int {
  this.jsDict.size()
}

def JsonObject.keys(): [String] {
  var badcodingstyle: Any = this.jsDict.keys()
  badcodingstyle.cast([String])
}

def JsonObject.get(key: String): JsonValue {
  this.jsDict.get(key).cast(JsonValue)
}

def JsonObject.set(key: String, value: JsonValue) {
  this.jsDict.set(key, value)
}

def JsonObject.remove(key: String) {
  this.jsDict.remove(key)
}

def jsonEscape(str: String): String {
  var buf = new StrBuf()
  var len = str.len()
  for (var i=0, i<len, i+=1) {
    var ch = str[i]
    switch (ch) {
      '"':  buf.append("\\\"")
      '\\': buf.append("\\\\")
      '/':  buf.append("\\/")
      '\r': buf.append("\\r")
      '\n': buf.append("\\n")
      '\b': buf.append("\\b")
      '\f': buf.append("\\f")
      '\t': buf.append("\\t")
      else: buf.append(ch)
    }
  }
  buf.tostr()
}

def JsonValue.printInto(buf: StrBuf) {
  switch (this.jsType) {
    JSON_BOOL:
      buf.append(if (this.cast(JsonBool).jsBool) "true" else "false")
    JSON_STRING:
      buf.append("\"" + jsonEscape(this.cast(JsonString).jsString) + "\"")
    JSON_NUMBER: {
      buf.append(this.cast(JsonNumber).jsNumber)
    }
    JSON_ARRAY: {
      buf.append('[')
      var values = this.cast(JsonArray).jsList
      var len = values.len()
      for (var i=0, i<len, i+=1) {
        if (i != 0) buf.append(',')
        values[i].cast(JsonValue).printInto(buf)
      }
      buf.append(']')
    }
    JSON_OBJECT: {
      buf.append('{')
      var dict = this.cast(JsonObject).jsDict
      var keys = dict.keys()
      for (var i=0, i<keys.len, i+=1) {
        var key = keys[i].cast(String)
        if (i != 0) buf.append(',')
        buf.append('"').append(jsonEscape(key)).append("\":")
        dict[key].cast(JsonValue).printInto(buf)
      }
      buf.append('}')
    }
    else:
      buf.append("null")
  }
}

def JsonValue.tostr(): String {
  var buf = new StrBuf()
  this.printInto(buf)
  buf.tostr()
}
