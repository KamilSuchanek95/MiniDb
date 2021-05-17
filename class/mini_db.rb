require_relative 'db_variables'
require 'set'

class MiniDb < DbVariables
  attr_accessor :db_variables, :name

  @@current_db_name  = ""
  @@databases_names = Set.new
  @@databases       = Array.new
  
  @transaction_rollup = Array.new
  @transaction_changed_variables = Array.new
  @transaction_state = -1

  def initialize(db_name)
    # TODO: check if name is in use and add postfix with number eventually
    @@databases_names <<  db_name # save name to unique list

    @@databases       <<  self # add reference to object inside class
    @@current_db_name << db_name # active db workflow

    @name             = db_name # name of database
    @db_variables     = DbVariables.new # create list variables
  end

  def set name, value, variables_list = self.db_variables.variables_list
    if(transaction_in_progress? and variable_unchanged?)
      @transaction_changed_variables << name
      @transaction_rollup[@transaction_state] << "set #{name} #{value}"
    end

    super
  end

  def get name, variables_list = self.db_variables.variables_list
    super
  end
  
  def delete name, variables_list = self.db_variables.variables_list
    super
  end

  def count value, variables_list = self.db_variables.variables_list
    super
  end

  def begin_transaction
    @transaction_state += 1
    @transaction_rollup << Array.new # [@transaction_state][el]
    #@transaction_changed_variables << Array.new
  end

  def commit_transactions
    @transaction_state = -1
    @transaction_rollup = Array.new
    @transaction_changed_variables = Array.new
  end

  def rollup_transaction
    # TODO: parse @transaction_rollup to blocks 
    #       clean @transaction_rollup and changed raviables list
    @transaction_rollup[@transaction_state].each do |change|
      # ... parse and invert changes.
    end

    @transaction_state -= 1
  end

  # return reference to database
  def select db_name
    if database_exists? 
      @@current_db_name = db_name
      @@databases.select {|db| db.name == db_name}
    end
  end

  def destroy db_name
    if database_exists?
      @@databases.delete {|db| db.name == db_name}
      @@current_db_name = "" if @@current_db_name == db_name
      @databases_names.delete db_name
    end
  end

  def self.list
    @@databases_names
  end

  def self.count
    @@databases.count
  end

  private

  def database_exists? name
    @@databases.include?(name)
  end

  def variable_unchanged? # return false if we want to change them, so !()
    !(@transaction_changed_variables.include?(name))
  end

  def transaction_in_progress?
    (@transaction_state > -1)
  end

end