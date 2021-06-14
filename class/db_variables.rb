class DbVariables

  def initialize
    @variables_list = Hash.new
  end

  def set name, value
    # TODO: Exception/Error handling
    if  validate_name(name) and validate_value(value)
      @variables_list[name.to_s.delete(" \t\r\n").to_sym] = value.to_s.delete(" \t\r\n")
    end
  end

  def get name
    # jeśli mamy taką zmienną to ją zwróć, jesli nie, zwracamy NULL
    if validate_name(name) and variable_exists?(name)
      return @variables_list[name.to_sym]
    else
      return "NULL"
    end
  end
  
  def delete name
    # Jeśli takiej zmiennej i tak nie było to zwróci nil
    @variables_list.delete(name.to_sym) if validate_name name
  end

  def count value
    # Zwróci 0 albo więcej.
    @variables_list.values.count(value) if validate_value value
  end

  def variable_exists? name
    @variables_list.include?(name.to_sym)
  end



  private

  def validate_name name
    name.respond_to?(:to_sym)
  end

  def validate_value value
    value.respond_to?(:to_s)
  end
end