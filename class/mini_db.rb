require_relative 'db_transactions'
require 'set'
require 'pry'

##
# This class creates and manage simple databases-in memory
class MiniDb

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
    @@databases.delete {|db| db.name == self.db_name}
    @@databases_names.delete self.db_name
    'Only this instance contain now data, but no longer is this in class memory'
  end

  # methods for variables
  def set var_name, value
    @db_transactions.manage_transactions __method__, var_name
    @variables_list[var_name.to_sym] = value.to_s
  end  
  
  def get var_name
    variable_exists?(var_name) ? @variables_list[var_name.to_sym] : 'NULL'
  end
  
  def delete var_name
    @db_transactions.manage_transactions __method__, var_name
    @variables_list.delete var_name.to_sym
  end

  def count value
    @variables_list.values.count value
  end

  def variable_exists? var_name
    @variables_list.include?(var_name.to_sym)
  end

  # methods for transactions
  def begin
    @db_transactions.begin
  end

  def commit
    @db_transactions.commit
  end

  def rollback
    @db_transactions.rollback
  end

  #class methods
  def self.select db_name 
    database_exists? ? @@databases.select {|db| db.name == db_name} : nil
  end

  def self.destroy db_name
    if database_exists?
      @@databases.delete {|db| db.name == db_name}
      @databases_names.delete db_name
    end
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