require_relative './class/mini_db.rb'
require_relative './class/db_variables.rb'

require 'pry'


db1 = MiniDb.new("app1")

db1.set "var1", "val1"
db1.set "var2", "val2"
db1.set "var3", "val3"
db1.db_variables.set "var4", "val4"
db1.set "var5", "val5"

out1 = db1.get "var1"
puts "get:1 ==> " + (out1 || "nil")
out1 = db1.db_variables.get "var1"
puts "get:1 ==> " + (out1 || "nil")

out1 = db1.get "var10"
puts "get:10 ==> " + (out1 || "nil")

db1.delete "var1"
out1 = db1.get "var1"
puts "get after delete:1 ==> " + (out1 || "nil")
db1.db_variables.delete "var2"
out1 = db1.get "var2"
puts "get after delete:2 ==> " + (out1 || "nil")

