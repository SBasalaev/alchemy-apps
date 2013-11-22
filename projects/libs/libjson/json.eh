/* Types of JSON values. */
const JSON_NULL = 0
const JSON_STRING = 1
const JSON_NUMBER = 2
const JSON_BOOL = 3
const JSON_ARRAY = 4
const JSON_OBJECT = 5

type JsonValue;

def JsonValue.getType(): Int;
def JsonValue.tostr(): String;

/* Utility functions. */
def jsonEscape(str: String): String;
type Reader;
def jsonParse(r: Reader): JsonValue;
def jsonParseString(str: String): JsonValue;

/* JSON value abstractions. */

type JsonNull < JsonValue;

def JsonNull.new();

type JsonString < JsonValue;

def JsonString.new(val: String);
def JsonString.getValue(): String;

type JsonNumber < JsonValue;

def JsonNumber.new(val: Double);
def JsonNumber.getValue(): Double;

type JsonBool < JsonValue;

def JsonBool.new(val: Bool);
def JsonBool.getValue(): Bool;

type JsonArray < JsonValue;

def JsonArray.new();
def JsonArray.len(): Int;
def JsonArray.get(index: Int): JsonValue;
def JsonArray.set(index: Int, val: JsonValue);
def JsonArray.insert(index: Int, val: JsonValue);
def JsonArray.add(val: JsonValue);
def JsonArray.toarray(): [JsonValue];

type JsonObject < JsonValue;

def JsonObject.new();
def JsonObject.len(): Int;
def JsonObject.keys(): [String];
def JsonObject.get(key: String): JsonValue;
def JsonObject.set(key: String, value: JsonValue);
def JsonObject.remove(key: String);
