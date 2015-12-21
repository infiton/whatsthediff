class ProjectRowLoader
  include ActiveModel::Model

  def initialize(project, data_type, data_chunk)
    @project = project
    @data_type = data_type
    @data_chunk = data_chunk

    build_rows
  end

  def call
    return false unless @rows && @rows.any?
    
    if ActiveRecord::Base.transaction { connection.insert(sql) }
      @rows.count
    else
      false
    end
  end

  private
    def build_rows
      return false unless valid_type?

      rows = []
      @data_chunk.each do |row|
        next unless row[:uid] && row[:digest]
        rows << @project.send(row_type).build(uid: row[:uid], digest: row[:digest])
      end

      return false unless rows.any?
      @rows = rows
    end

    def row_type
      "#{@data_type}_rows"
    end

    def valid_type?
      @project.respond_to?(row_type)
    end

    def connection
      @connection ||= ActiveRecord::Base.connection
    end

    def table
      @table ||= ProjectRow.arel_table
    end

    def table_name
      connection.quote_table_name(table.name)
    end

    def columns
      @columns ||= connection.columns(table.name).reject{|c| ["id", "created_at", "updated_at"].include?(c.name)}
    end

    def column_names
      columns.map{ |c| connection.quote_column_name(c.name) }.join(", ")
    end

    def sql
      qry = "INSERT INTO #{table_name} (#{column_names}) VALUES "

      qry += @rows.map {|row|
        "(#{columns.map {|column| connection.quote(row.send(column.name), column)}.join(", ")})"
      }.join(", ")

      qry
    end
      
end