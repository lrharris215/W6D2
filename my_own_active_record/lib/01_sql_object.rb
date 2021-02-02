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
    findyfind = DBConnection.execute(<<-SQL, id)
      SELECT * FROM #{self.table_name} WHERE #{self.table_name}.id = ?

    SQL
    parse_all(findyfind).first
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
    self.class.columns.map do |attr|
      self.send(attr)
    end
    # ...
  end

  def insert
    cols = self.class.columns.drop(1)
    col_names = cols.map(&:to_s).join(", ")


    question_marks = (["?"] * cols.count).join(", ")
    puts "cols: #{cols}"
    puts "col_names: #{col_names}"
    puts "questions: #{question_marks}"
    DBConnection.execute(<<-SQL, *attribute_values.drop(1))

    INSERT INTO
      #{self.class.table_name} (#{col_names})
    VALUES
      (#{question_marks})

    SQL

    self.id = DBConnection.last_insert_row_id
    # ...
  end

  def update
    set_vals = self.class.columns.map{ |attr| "#{attr} = ?"}.join(", ")

    DBConnection.execute(<<-SQL, *attribute_values, self.id)
      UPDATE
        #{self.class.table_name}
      SET
        #{set_vals}
      WHERE
        id = ?
      
      SQL
    
    # ...
  end

  def save
    insert if self.id.nil?
    update
    # ...
  end
end
