require_relative 'db_connection'
require 'active_support/inflector'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject

  

  def self.columns
    return @columns if @columns
    columns = DBConnection.execute2(<<-SQL).first
      SELECT * FROM #{self.table_name} 
    SQL
    columns.map!{|col| col.to_sym}
    @columns = columns
  end

  def self.finalize!
    self.columns.each do |col|
       define_method(col) do
        self.attributes[col]
      end
      define_method("#{col}=") do |new_val|
        self.attributes[col] = new_val
      end

    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
    
  end

  def self.table_name
    @table_name ||= self.name.tableize
   
  end

  def self.all
    all_things = DBConnection.execute(<<-SQL)
    SELECT * FROM #{self.table_name}

    SQL
    self.parse_all(all_things)
    # ...
  end

  def self.parse_all(results)
    ruby_things = []
    results.each do |object|
      ruby_things << self.new(object)
    end
    ruby_things
    
    # ...
  end

  def self.find(id)
    # ...
  end

  def initialize(params = {})
    params.each do |key, val|
      k = key.to_sym
      raise "unknown attribute '#{k}'" if !self.class.columns.include?(k)
      self.send("#{k}=", val)
    end
    # ...
  end

  def attributes
    @attributes ||= {}
    # ...
  end

  def attribute_values
    # ...
  end

  def insert
    # ...
  end

  def update
    # ...
  end

  def save
    # ...
  end
end
