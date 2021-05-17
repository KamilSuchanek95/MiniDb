require_relative File.expand_path(File.dirname(__FILE__)).gsub('/spec', '')+'/class/mini_db.rb'
require_relative File.expand_path(File.dirname(__FILE__)).gsub('/spec', '')+'/class/db_variables.rb'



describe DbVariables do
  context "Sprawdzenie czy komendy set/get/delete działają prawidłowo" do
    
    #1
    it "powinno zwrócić NULL, ponieważ nie ma takiej zmiennej" do
      dv = DbVariables.new
      message = dv.get "nie_ma_takiej"
      expect(message).to eq "NULL"
    end

    #2
    it "powinno utworzyć nową zmienną" do
      dv = DbVariables.new
      dv.set "zmienna1", "wartość1"
      content = dv.get "zmienna1"
      expect(content).to eq "wartość1"
    end

    #3
    it "powinno usunąć element" do
      dv = DbVariables.new
      dv.set "zmienna1", "wartość1"
      content = dv.delete "zmienna1"
      content = dv.get "zmienna1"
      expect(content).to eq "NULL"
    end

    #4
    it "powinno podać liczbę zmiennych" do
      dv = DbVariables.new
      dv.set "zmienna1", "wartość1"
      dv.set "zmienna2", "wartość2"
      dv.set "zmienna3", "wartość3"
      dv.set "zmienna4", "wartość3"
      dv.set "zmienna5", "wartość3"
      count = dv.count "wartość3"
      expect(count).to eq 3
    end
  end

  context "metody prywatne" do
    
    #5
    it "powinno dać znać, że zmienna istnieje" do
      dv = DbVariables.new
      dv.set "zmienna1", "wartość1"
      bool = dv.send(:variable_exists?, "zmienna1")
      expect(bool).to eq true
    end

    #6
    it "powinno powiedzieć, że zmiennej nie ma" do
      dv = DbVariables.new
      bool = dv.send(:variable_exists?, "zmienna1")
      expect(bool).to eq false
    end

    #7
    it "powinno stwierdzić, czy coś można zmienić w symbol" do
      dv = DbVariables.new
      bool = dv.send(:validate_name, "zmienna1")
      expect(bool).to eq true
    end

    #8
    it "powinno stwierdzić, czy coś można zmienić w string" do
      dv = DbVariables.new
      bool = dv.send(:validate_value, 21432536)
      expect(bool).to eq true
    end

  end
end