require_relative 'db_variables'
require 'set'


class MiniDb
  attr_accessor :db_variables, :name

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

    @transaction_rollback           = Array.new
    @transaction_changed_variables  = Array.new
    @transaction_state              = -1
  end

  def set name, value
    # Czy transakcja jest w toku oraz czy ta zmienna była już zmieniana? 
    if(transaction_in_progress? and variable_unchanged?(name))
      # jeśli już była to zapisz ją w tablicy zmian
      @transaction_changed_variables[@transaction_state] << name
      # jeśli wcześniej jej nie było, zapiszemy sobie polecenie usunięcia, a jeśli była to tylko nadpisania.
      command = variable_exists?(name) ? "set" : "delete"
      # oraz ten sam warunek, jeśli chcemy ją potem nadpisać to zapiszemy w tej chwili starą wartość.
      old_value = variable_exists?(name) ? self.get(name) : value
      # i tworzymy zapis potrzebny do odkręcenia zmian
      @transaction_rollback[@transaction_state] << "#{command} #{name} #{old_value}"
    end

    @db_variables.set name, value
  end
  
  
  
  def delete name
    # Tutaj analogicznie, jednak jedyną radą na usuwanie jest dodawanie, więc krócej.
    if(transaction_in_progress? and variable_unchanged?(name))
      @transaction_changed_variables[@transaction_state] << name
      value = self.get name
      @transaction_rollback[@transaction_state] << "set #{name} #{value}"
    end

    @db_variables.delete name
  end

  def get name
    @db_variables.get name
  end

  def count value
    @db_variables.count value
  end

  # Rozpocznij transakcję
  def begin
    # zwiększ liczbę transakcji, 0, to jedna, 1 to dwie, ta zmienna posłuży za index do operowania zmianami
    @transaction_state += 1
    # dołącz podmacierz, każda transakcja posiada własną podmacierz na zmiany, pod powyższym indeksem.
    @transaction_rollback           <<  Array.new # ARRAY[@transaction_state][change]
    @transaction_changed_variables  <<  Array.new
    return nil
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
        command == "set" ? self.set(name, value) : self.delete(name)
      end
      # usuń ostatnie elementy macierzy zmian (znajdują się pod aktualnym indeksem transakcji)
      # oraz przywróć wartość początkową -1
      @transaction_changed_variables.pop
      @transaction_rollback.pop
      @transaction_state -= 1
      return nil
    else
      "NO TRANSACTION"
    end
  end

  # To akurat niepotrzebne, w zamian pozostawię sam wybór po nazwie.
  # # Zwróć referencję do aktualnej bazy danych / W ten sposób można przełączyć się pomiędzy bazami.
  # #   (To samo ma miejsce podczas tworzenia nowej bazy)
  # def select db_name
  #   if database_exists? 
  #     @@current_db_name = db_name
  #     @@databases.select {|db| db.name == db_name}
  #   end
  # end
  def self.select db_name 
    database_exists? ? @@databases.select {|db| db.name == db_name} : nil
  end

  def self.destroy db_name
    if database_exists?
      @@databases.delete {|db| db.name == db_name}
      @databases_names.delete db_name
    end
  end

  def destroy
    @@databases.delete {|db| db.name == self.db_name}
    @@databases_names.delete self.db_name
    'only this instance contain now data, but no longer is this in class memory'
  end

  # Lista baz danych
  def self.list
    @@databases_names
  end



  private

  def database_exists? name
    @@databases_names.include?(name)
  end

  def variable_unchanged? name
    # !(@transaction_changed_variables.flatten.include?(name))
    !(@transaction_changed_variables[@transaction_state].include?(name))
  end

  def transaction_in_progress?
    (@transaction_state > -1)
  end

  def variable_exists? name
    self.db_variables.variable_exists? name
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