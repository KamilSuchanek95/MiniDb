require_relative 'db_variables'
require_relative 'db_transactions'
require 'set'


class MiniDb
  attr_accessor :db_variables, :name, :db_transactions

  # @@current_db_name  = ""
  @@databases_names = Set.new   # nazwy baz danych
  @@databases       = Array.new # Tutaj będą przechowywane referencje do wszystkich baz danych

  def initialize(db_name)
    db_name = check_db_name(db_name) if database_exists?(db_name)
    @@databases_names <<  db_name # save name to unique list

    @@databases       <<  self # add reference to object inside class
    # @@current_db_name << db_name # active db workflow

    @name             = db_name # name of database
    @db_variables     = DbVariables.new # create list variables
  
    @db_transactions = DbTransactions.new self
  end

  # methods for variables
  def set name, value
    @db_transactions.manage_transactions __method__, name, value
    @db_variables.set name, value
  end
  
  def delete name
    @db_transactions.manage_transactions __method__, name
    @db_variables.delete name
  end

  def get name
    @db_variables.get name
  end

  def count value
    @db_variables.count value
  end

  def variable_exists? name
    self.db_variables.variable_exists? name
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

  # def destroy
    # @@databases.delete {|db| db.name == self.db_name}
    # @@databases_names.delete self.db_name
    # 'only this instance contain now data, but no longer is this in class memory'
  # end


  private

  def database_exists? name
    @@databases_names.include?(name)
  end

  def check_db_name(db_name)
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