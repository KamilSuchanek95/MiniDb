require_relative 'db_variables'

class MiniDb

  @@current_db_name  = ""
  @@databases_names = Set.new
  @@databases       = Array.new

  def def initialize(db_name)
    # TODO: check if name is in use and add postfix with number eventually
    @@databases_names <<  db_name # save name to unique list
    @db_variables     = DbVariables.new # create list variables
    @@databases       <<  self # add reference to object inside class
    @@current_db_name << db_name # active db workflow
    @name             = db_name
  end

  def select db_name
    @@databases.select {|db| db.name == db_name}

  def self.all
    @databases.inspect
  end

  def self.count
    @@databases.count
  end
end