require_relative File.expand_path(File.dirname(__FILE__)).gsub('/spec', '')+'/class/mini_db.rb'
require_relative File.expand_path(File.dirname(__FILE__)).gsub('/spec', '')+'/class/db_variables.rb'

describe MiniDb do
  
  context "Spradzenie jak działają metody dziedziczone" do
    
    #1
    it "powinno zwrócić NULL, ponieważ nie ma takiej zmiennej" do
      md = MiniDb.new "name1"
      message = md.get "nie_ma_takiej"
      expect(message).to eq "NULL"
    end

    #2
    it "powinno utworzyć nową zmienną" do
      md = MiniDb.new "name1"
      md.set "zmienna1", "wartość1"
      content = md.get "zmienna1"
      expect(content).to eq "wartość1"
    end

    #3
    it "powinno usunąć element" do
      md = MiniDb.new "name1"
      md.set "zmienna1", "wartość1"
      content = md.delete "zmienna1"
      content = md.get "zmienna1"
      expect(content).to eq "NULL"
    end

    #4
    it "powinno podać liczbę zmiennych" do
      md = MiniDb.new "name1"
      md.set "zmienna1", "wartość1"
      md.set "zmienna2", "wartość2"
      md.set "zmienna3", "wartość3"
      md.set "zmienna4", "wartość3"
      md.set "zmienna5", "wartość3"
      count = md.count "wartość3"
      expect(count).to eq 3
    end
  end

  context "Sprawdzanie działania transakcji" do
    
    #5
    it "powinno poinformować o braku aktywnej transakcji po wywołaniu commit" do
      md = MiniDb.new "name1"
      message = md.commit
      expect(message).to eq "NO TRANSACTION"
    end

    #6
    it "powinno poinformować o braku aktywnej transakcji po wywołaniu rollback" do
      md = MiniDb.new "name1"
      message = md.rollback
      expect(message).to eq "NO TRANSACTION"
    end

    #7
    it "powinno rozpocząć i zakończyć transakcję bez problemów" do
      md = MiniDb.new "name1"
      md.begin
      md.rollback
      md.begin
      md.commit
    end

    #8
    it "powinno zachować zapisaną zmienną w transakcji" do
      md = MiniDb.new "name1"
      md.begin
      md.set "Tzmienna1", "Twartość1"
      md.commit
      value = md.get "Tzmienna1"
      expect(value).to eq "Twartość1"
    end

    #9
    it "powinno zachować zapisaną zmienną w transakcji zagnieżdżonej wewnętrznej" do
      md = MiniDb.new "name1"
      md.begin
      md.begin
      md.set "Tzmienna1", "Twartość1"
      md.commit
      value = md.get "Tzmienna1"
      expect(value).to eq "Twartość1"
    end    

    #10
    it "powinno zachować zapisaną zmienną w transakcji zagnieżdżonej zewnętrznej" do
      md = MiniDb.new "name1"
      md.begin
      md.set "Tzmienna1", "Twartość1"
      md.begin
      md.commit
      value = md.get "Tzmienna1"
      expect(value).to eq "Twartość1"
    end

    #11
    it "powinno usunąć zmienne z transakcji" do
      md = MiniDb.new "name1"
      md.begin
      md.set "Tzmienna1", "Twartość1"
      md.rollback
      value = md.get "Tzmienna1"
      expect(value).to eq "NULL"
    end

    #12
    it "powinno usunąć zmienne z transakcji wewnętrznej" do
      md = MiniDb.new "name1"
      md.begin
      md.begin
      md.set "Tzmienna1", "Twartość1"
      md.rollback
      md.commit
      value = md.get "Tzmienna1"
      expect(value).to eq "NULL"
    end

    #13
    it "powinno usunąć zmienne z transakcji zewnętrznej" do
      md = MiniDb.new "name1"
      md.begin
      md.set "Tzmienna1", "Twartość1"
      md.begin
      md.rollback
      md.rollback
      value = md.get "Tzmienna1"
      expect(value).to eq "NULL"
    end

    #14 
    it "powinno zachować zmienną utworzoną w zewnętrznej transakcji a usuniętej w wewnętrznej lecz wycofanej" do
      md = MiniDb.new "name1"
      md.set "zmienna1", "wartość1"
        md.begin
        md.set "Tzmienna1", "Twartość1"
        md.set "zmienna1", "wartość1_T1"
          md.begin
          md.delete "Tzmienna1"
          md.set "zmienna1", "wartość_T2"
          md.rollback
        md.commit

      value = md.get "Tzmienna1"
      expect(value).to eq "Twartość1"
    end

    #14'
    it "powinno zachować zmianę wartości w transakcji zewnetrznej pomimo ponownej zmiany w transakcji wewnętrznej" do
      md = MiniDb.new "name1"
      md.set "zmienna1", "wartość1"
        md.begin
        md.set "Tzmienna1", "Twartość1"
        md.set "zmienna1", "wartość1_T1"
          md.begin
          md.delete "Tzmienna1"
          md.set "zmienna1", "wartość_T2"
          md.rollback
        md.commit

      value = md.get "zmienna1"
      expect(value).to eq "wartość1_T1"
    end

  end
end
