require_relative 'db_transactions'
require 'set'

##
# This class creates and manage simple databases-in memory
class MiniDb

  @@databases_names = Set.new
  @@databases       = Array.new

  def initialize(db_name)
    @@databases_names <<  db_name
    @@databases       <<  self

    @name             = customize_db_name db_name
    #@db_variables     = DbVariables.new
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
      # TODO: To działa, jednak jeśli ponownie utworzymy bazę z tą samą nazwą to w ten sposób nadpiszemy poprzednio
      # utworzoną bazę "z kolejnym numerem", np. utworzymy app, teraz ponownie app, otrzymamy app_2, jeśli po raz
      # trzeci utworzymy app to nadpiszemy app_2.
      # Więc w tym miejscu należaloby przeszukać zestaw @databases_names za zawierającymi ten sam "raw_name" i 
      # uciąć sobie z niego najwiekszy numer po podłodze.
      number = db_name.slice(/\d+$/).to_i
      number > 0 ? number +=1 : 2
      db_name = raw_name + "_#{number}"
    end
  end

end