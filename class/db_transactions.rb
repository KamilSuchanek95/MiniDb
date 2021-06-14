##
# This class managed transactions for MiniDb object of database.

class DbTransactions

  def initialize(database)
    @operations_to_rollback      = Array.new
    @names_of_changed_variables  = Array.new
    @level                       = -1

    @database = database
  end

  def manage_transactions method, *args
    name = args[0].to_s
    
    if ready_to_transaction? name
      case method
      when :set
        value = args[1].to_s
        # Czy transakcja jest w toku oraz czy ta zmienna była już zmieniana? 
      
          # jeśli już była zmieniana w transakcji to zapisz ją w tablicy zmian
        @names_of_changed_variables[@level] << name
          #         nowa zmienna?  potem =>  nadpisz  :  usuń
          # command = variable_exists?(name) ? "set" : "delete"
          # oraz ten sam warunek, jeśli chcemy ją potem nadpisać to zapiszemy w tej chwili starą wartość.
          # old_value = variable_exists?(name) ? @database.db_variables.get(name) : value
          # i tworzymy zapis potrzebny do odkręcenia zmian
          # @operations_to_rollback[@level] << "#{command} #{name} #{old_value}"
        if @database.variable_exists? name
          old_value = @database.db_variables.get(name)
          @operations_to_rollback[@level] << -> {@database.set(name, old_value)}
        else
          @operations_to_rollback[@level] << -> {@database.delete(name)}
        end
      when :delete
        # Tutaj analogicznie, jednak jedyną radą na usuwanie jest dodawanie, więc krócej.
        @names_of_changed_variables[@level] << name
        value = @database.db_variables.get name
        #@operations_to_rollback[@level] << "set #{name} #{value}"
        @operations_to_rollback[@level] << -> {@database.set(name, value)}
      else
        'This method can only be used with set and delete commands'
      end
    end
  end

  def begin
    # zwiększ liczbę transakcji, 0, to jedna, 1 to dwie, ta zmienna posłuży za index do operowania zmianami
    @level += 1
    # dołącz podmacierz, każda transakcja posiada własną podmacierz na zmiany, pod powyższym indeksem.
    @operations_to_rollback      <<  Array.new # ARRAY[@level][changes]
    @names_of_changed_variables  <<  Array.new
    "TRANSACTION LEVEL #{@level + 1}"
  end

  # Zatwierdź wszystkie transakcje
  def commit
    transaction_in_progress? ? complete_transaction : "NO TRANSACTION"
  end

  # Wycofaj transakcję
  def rollback
    # Czy transakcja jest w toku?
    if transaction_in_progress?
      # dla każdej zmiany w tejże transakcji:
      @operations_to_rollback[@level].each do |change| 
        # wyodrębij metodę (set/delete), nazwę zmiennej oraz jej wartość
        # command, name, value = change.split(" ")
        # w celu odwrócenia naniesionych w trakcie transakcji zmian
        # command == "set" ? @database.db_variables.set(name, value) : @database.db_variables.delete(name)
        change.call
      end
      clear_current_transaction
      "Level #{@level + 2} TRANSACTION ROLLED BACK\nCURRENT TRANSACTION LEVEL IS #{@level + 1}"
    else
      "NO TRANSACTION"
    end
  end



  
  private

  def ready_to_transaction? name
    transaction_in_progress? and variable_unchanged?(name)
  end

  def variable_unchanged? name
    # !(@names_of_changed_variables.flatten.include?(name))
    !(@names_of_changed_variables[@level].include?(name))
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
    # usuń ostatnie elementy macierzy zmian (znajdują się pod aktualnym indeksem transakcji)
    # oraz przywróć wartość początkową -1
    @names_of_changed_variables.pop
    @operations_to_rollback.pop
    @level -= 1
  end
end