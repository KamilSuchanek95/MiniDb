require_relative 'db_transactions'
require 'set'
require 'pry'

##
# This class creates and manage simple databases-in memory
class MiniDb
  attr_accessor :name

  @@databases_names = Set.new
  @@databases       = Array.new

  def initialize(db_name)
    @name             = customize_db_name db_name # this line must be first.

    @@databases_names <<  @name
    @@databases       <<  self

    @variables_list   = Hash.new
    @db_transactions  = DbTransactions.new self
  end

  def destroy
    @@databases.delete self
    @@databases_names.delete @name
    "Database #{@name} has been successfully removed from class memory\nThis object is last source of data"
  end


  # methods for variables
  def set var_name, value
    @db_transactions.manage_transactions __method__, var_name
    @variables_list[var_name.to_sym] = value.to_s
  end  

  def delete var_name
    @db_transactions.manage_transactions __method__, var_name
    @variables_list.delete var_name.to_sym
  end

  def get var_name
    variable_exists?(var_name) ? @variables_list[var_name.to_sym] : 'NULL'
  end
  
  def count value
    @variables_list.values.count value
  end

  def variable_exists? var_name
    @variables_list.include?(var_name.to_sym)
  end

  # methods for transactions  - only delegations to DbTransactions class
  def begin;    @db_transactions.begin    end
  def commit;   @db_transactions.commit   end
  def rollback; @db_transactions.rollback end

  #class methods
  def self.select db_name 
    @@databases_names.include?(db_name) ? @@databases.find {|db| db.name == db_name} : nil
  end

  def self.list
    @@databases_names
  end




  private


  def database_exists? db_name
    @@databases_names.include?(db_name)
  end
  
  def customize_db_name(db_name)
    if database_exists? db_name
      raw_name = db_name.split(/_\d+$/)[0] # odetnij "_<JakasLiczba>", ale tylko na końcu.
      matched_names = @@databases_names.grep /#{raw_name}_\d+$/ # zwróć pasujące nazwy
      
      if matched_names.empty? # jeśli jeszcze nie było dubla 
        db_name = "#{raw_name}_2" # to tylko dodaj _2 do nazwy
      else # a jeśli do dubel to dostosuj nazwę : nazwabazy_N
        numbers       = matched_names.map { |d| d.slice(/\d+$/).to_i } # numery takich samych nazw
        new_number    = numbers.max + 1 # największy numer + 1
        db_name = raw_name + "_#{new_number}" # nowa nazwa
      end
    end
    return db_name
  end

end