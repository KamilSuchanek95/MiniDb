##
# This class manages transactions for MiniDb object of database.
class DbTransactions

  def initialize(database)
    @operations_to_rollback      = Array.new
    @names_of_changed_variables  = Array.new
    @level                       = -1

    @database = database
  end

  def manage_transactions method, var_name
    if ready_to_transaction? var_name

      @names_of_changed_variables[@level] << var_name
      
      case method
      when :set
        add_var_removal_or_overwrite_if_it_already_exists var_name
      when :delete
        add_var_overwrite_when_it_is_removed var_name
      else
        'This method can only be used with set and delete commands'
        @names_of_changed_variables[@level].delete
      end
    end
  end

  def begin
    init_transaction
    "TRANSACTION LEVEL #{@level + 1}"
  end

  def commit
    transaction_in_progress? ? complete_transaction : 'NO TRANSACTION'
  end

  def rollback
    if transaction_in_progress?
      call_saved_lambdas_to_rollback_changes
      clear_current_transaction
      "Level #{@level + 2} TRANSACTION ROLLED BACK\nCURRENT TRANSACTION LEVEL IS #{@level + 1}"
    else
      'NO TRANSACTION'
    end
  end



  
  private

  def ready_to_transaction? var_name
    transaction_in_progress? and variable_unchanged?(var_name)
  end

  def variable_unchanged? var_name
    !(@names_of_changed_variables[@level].include?(var_name))
  end

  def transaction_in_progress?
    @level > -1
  end

  def complete_transaction
    @level                      = -1
    @operations_to_rollback     = Array.new
    @names_of_changed_variables = Array.new
  end

  def clear_current_transaction
    @names_of_changed_variables.pop
    @operations_to_rollback.pop
    @level -= 1
  end

  def init_transaction
    @level += 1
    @operations_to_rollback      <<  Array.new # ARRAY[@level][changes]
    @names_of_changed_variables  <<  Array.new
  end

  def call_saved_lambdas_to_rollback_changes
    @operations_to_rollback[@level].each { |change| change.call }
  end

  # hmm ta nazwa to na pewno dobry pomysł?..
  def add_var_removal_or_overwrite_if_it_already_exists var_name
    if @database.variable_exists? var_name
      old_value = @database.get(var_name)
      @operations_to_rollback[@level] << -> {@database.set(var_name, old_value)}
    else
      @operations_to_rollback[@level] << -> {@database.delete(var_name)}
    end
  end

  def add_var_overwrite_when_it_is_removed var_name
    @names_of_changed_variables[@level] << var_name
    value = @database.get var_name
    @operations_to_rollback[@level] << -> {@database.set(var_name, value)}
  end
end