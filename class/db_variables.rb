class DbVariables
  attr_accessor :variables_list

  def initialize
    @variables_list = Hash.new
  end

  def set name, value, variables_list = @variables_list
    # TODO: Exception/Error handling
    if  validate_name(name) and validate_value(value)
      variables_list[name.to_s.delete(" \t\r\n").to_sym] = value.to_s.delete(" \t\r\n")
    end
  end

  def get name, variables_list = @variables_list
    # TODO: If name doesnt exist? => nil, "NULL"
    variables_list[name.to_sym] if validate_name name
  end
  
  def delete name, variables_list = @variables_list
    # If that key doesnt exist => nil
    variables_list.delete(name.to_sym) if validate_name name
  end

  def count value, variables_list = @variables_list
    # count or 0, fine.
    variables_list.values.count(value) if validate_value value
  end


  private

  def validate_name name
    name.respond_to?(:to_sym)
  end

  def validate_value value
    value.respond_to?(:to_s)
  end
end