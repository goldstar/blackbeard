module Blackbeard
  class Chart
    attr_reader :dom_id

    def initialize(options)
      [:dom_id, :height, :title].each{|m| instance_variable_set("@#{m}", options[m]) }
      [:rows, :columns].each{|m| instance_variable_set("@#{m}", options[m] || []) }
    end

    def options
      {:title => @title, :height => height}
    end

    def data
      {:rows => rows, :cols => columns}
    end

private

    def height
      @height || 300
    end

    def rows
      @rows.map{ |r| row(r) }
    end

    def row(r)
      { :c => r.map{ |c| row_cell(c) } }
    end

    def row_cell(cell_value)
      { :v => cell_value }
    end

    def columns
      types = column_types
      @columns.map{ |label| column(label,types.shift) }
    end

    def column_types
      @rows.first.map{ |cell_value| cell_type(cell_value) }
    end

    def cell_type(value)
      case value.class.name
      when 'Fixnum'
        'number'
      when 'Float'
        'number'
      when 'String'
        'string'
      when 'Date'
        'string'
      else
        'string'
      end
    end

    def column(label, type)
      {:label => label, :type => type}
    end

  end
end
