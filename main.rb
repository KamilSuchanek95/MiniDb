require_relative './class/mini_db.rb'

require 'pry'


# Simple RSpec
# puts `rspec`

# Brudnopis / examples
db1 = MiniDb.new("app1")

db1.set "var1", "val1"
db1.set "var2", "val2"
db1.set "var3", "val3"
db1.set "var4", "val4"
db1.set "var5", "val5"

out1 = db1.get "var1"
puts "get:1 ==> " + (out1 || "nil")
out1 = db1.get "var1"
puts "get:1 ==> " + (out1 || "nil")

out1 = db1.get "var10"
puts "get:10 ==> " + (out1 || "nil")

db1.delete "var1"
out1 = db1.get "var1"
puts "get after delete:1 ==> " + (out1 || "nil")
db1.delete "var2"
out1 = db1.get "var2"
puts "get after delete:2 ==> " + (out1 || "nil")

# binding.pry

p 'rollback first:'
db1.rollback


p 'begin and rollback:'
db1.begin
db1.rollback

p 'begin, set, rollback'
db1.begin
db1.set "tvar1", "tval1"
db1.rollback

p 'begin, set, commit'
db1.begin
db1.set "tvar1", "tval1"
db1.commit

  p 'nested transactions:'
  p 'begin set and start nested'
  db1.begin
  db1.set "t1_var2", "t1_val2"
  db1.begin

    p 'set nested(2) variable'
    db1.set "t2_var2", "t2_val2"
    p 'rollback nested changes'
    db1.rollback

  db1.rollback

binding.pry