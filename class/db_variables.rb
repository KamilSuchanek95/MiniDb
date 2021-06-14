# ## Tego jest strasznie mało, a i tak trzeba to powtarzać,
# ## więc lepiej po prostu wcielę to w klasę bazy i już.
# # This class manage variables in Hash
# class DbVariables

#   def initialize
#     @variables_list = Hash.new
#   end

#   def set var_name, value
#     @variables_list[var_name.to_s.delete(" \t\r\n").to_sym] = value.to_s.delete(" \t\r\n")
#   end

#   def get var_name
#     if variable_exists?(var_name) ? @variables_list[var_name.to_sym] : 'NULL'
#   end
  
#   def delete var_name
#     @variables_list.delete var_name.to_sym
#   end

#   def count value
#     @variables_list.values.count value
#   end

#   def variable_exists? var_name
#     @variables_list.include?(var_name.to_sym)
#   end

# end