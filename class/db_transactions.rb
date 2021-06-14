

class DbTransactions

  def initialize(database)
    @transaction_rollback           = Array.new
    @transaction_changed_variables  = Array.new
    @transaction_state              = -1

    @database = database
  end

  def manage_transactions method, *args
    name = args[0].to_s
    case method
    when(:set)
      value = args[1].to_s
      # Czy transakcja jest w toku oraz czy ta zmienna była już zmieniana? 
      if(transaction_in_progress? and variable_unchanged?(name))
        # jeśli już była zmieniana w transakcji to zapisz ją w tablicy zmian
        @transaction_changed_variables[@transaction_state] << name
        #         nowa zmienna?  potem =>  nadpisz  :  usuń
        command = variable_exists?(name) ? "set" : "delete"
        # oraz ten sam warunek, jeśli chcemy ją potem nadpisać to zapiszemy w tej chwili starą wartość.
        old_value = variable_exists?(name) ? @database.db_variables.get(name) : value
        # i tworzymy zapis potrzebny do odkręcenia zmian
        @transaction_rollback[@transaction_state] << "#{command} #{name} #{old_value}"
      end
    when(:delete)
      # Tutaj analogicznie, jednak jedyną radą na usuwanie jest dodawanie, więc krócej.
      if(transaction_in_progress? and variable_unchanged?(name))
        @transaction_changed_variables[@transaction_state] << name
        value = @database.db_variables.get name
        @transaction_rollback[@transaction_state] << "set #{name} #{value}"
      end
    #else
      #'This method can only be used with set and delete commands'
    end
  end

  def begin
    # zwiększ liczbę transakcji, 0, to jedna, 1 to dwie, ta zmienna posłuży za index do operowania zmianami
    @transaction_state += 1
    # dołącz podmacierz, każda transakcja posiada własną podmacierz na zmiany, pod powyższym indeksem.
    @transaction_rollback           <<  Array.new # ARRAY[@transaction_state][changes]
    @transaction_changed_variables  <<  Array.new
    "TRANSACTION LEVEL #{@transaction_state + 1}"
  end

  # Zatwierdź wszystkie transakcje
  def commit
    if transaction_in_progress?
      # przywróć wartość początkową -1
      @transaction_state = -1
      # oraz zreseruj macierze zmian
      @transaction_rollback           = Array.new
      @transaction_changed_variables  = Array.new
      return nil
    else
      "NO TRANSACTION"
    end
  end

  # Wycofaj transakcję
  def rollback
    # Czy transakcja jest w toku?
    if transaction_in_progress?
      # dla każdej zmiany w tejże transakcji:
      @transaction_rollback[@transaction_state].each do |change| 
        # wyodrębij metodę (set/delete), nazwę zmiennej oraz jej wartość
        command, name, value = change.split(" ")
        # w celu odwrócenia naniesionych w trakcie transakcji zmian
        command == "set" ? @database.db_variables.set(name, value) : @database.db_variables.delete(name)
      end
      # usuń ostatnie elementy macierzy zmian (znajdują się pod aktualnym indeksem transakcji)
      # oraz przywróć wartość początkową -1
      @transaction_changed_variables.pop
      @transaction_rollback.pop
      @transaction_state -= 1
      "Level #{@transaction_state + 2} TRANSACTION ROLLED BACK\nCURRENT TRANSACTION LEVEL IS #{@transaction_state + 1}"
    else
      "NO TRANSACTION"
    end
  end




  private


  def variable_unchanged? name
    # !(@transaction_changed_variables.flatten.include?(name))
    !(@transaction_changed_variables[@transaction_state].include?(name))
  end

  def transaction_in_progress?
    (@transaction_state > -1)
  end

  def variable_exists? name
    @database.db_variables.variable_exists? name
  end

end