def check_simple_table_data(table_selector, table_data, origin)
  expect(page).to have_selector(table_selector)
  within(table_selector) do
    header_map = []
    row_count = table_data.raw.length - 1
    within("thead tr:first") do
        columns = all("th").collect{ |column| column.text.downcase.strip }
        expect(columns.size).to be >= (table_data.headers.size - 2)
      
        table_data.headers.each_with_index do |header, index|
          column = columns.index(header.downcase.strip)
          if !column.nil?
            header_map << column
          end
        end        
        if origin == "list"
          header_map << 12
          header_map << 13
        end
    end
  
    table_rows = table_data.raw[1...table_data.raw.length]

    within("tbody") do
      expect(all("tr").size).to eq(row_count)
      
      xpath_base = './/tr[%i]/td[%i]';
      table_rows.each_with_index do |row, index|
        row.each_with_index do |value, column|
          if origin == "list" && column == 7
            puts value
            @creator = User.find_by(username: value)
            
            if !@creator.present?
              puts "Autoridade"
              @creator = Authority.find_by(name: value)
            end
            
            @creator = @creator.id.to_s
            
            puts @creator
            expect(find(:xpath, xpath_base % [index + 1, header_map[column] + 1])).to have_content(@creator)
          else
            expect(find(:xpath, xpath_base % [index + 1, header_map[column] + 1])).to have_content(value)
          end
        end
      end
    end
  end
end

Então('deverei ver a lista de desastres da seguinte forma:') do |table|
  check_simple_table_data("#disasters table", table, "list")
end