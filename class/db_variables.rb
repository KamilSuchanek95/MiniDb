class DbVariables

  def initialize
    @variables_list = Hash.new
  end

  def set name, value
    # TODO: Exception/Error handling
    @variables_list[name.to_s.delete(" \t\r\n").to_sym]  = value.to_s.delete(" \t\r\n")  if  validate_name and validate_value
  end

  def get name
    # TODO: If name doesnt exist? => nil, "NULL"
    @variables_list[name.to_sym] if validate_name
  end
  
  def delete name
    # If that key doesnt exist => nil
    @variables_list.delete(name.to_sym) if validate_name
  end

  def count value
    # count or 0, fine.
    @variables_list.values.count(value) if validate_value
  end


  private

  def validate_name name
    name.respond_to?(:to_sym)
  end

  def validate_value value
    value.respond_to?(:to_s)
  end
end