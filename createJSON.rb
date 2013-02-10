# createJSON.rb
# Ben Garvey
# ben@bengarvey.com
# @bengarvey
# 2/9/2013
# Description:  Generates a JSON file for the Philadelphia education data based on school code.  It's needed to create a hierarchy from the flat CSV files.

require 'csv'
require 'json'

schooldata = Hash.new

# Key priority.  Assuming common field names across the csv files, it builds a hierarchy based on the order of the values here
keys = ['SCHOOL_CODE', 'SCHOOL_YEAR'];

# Find all the CSV files in this directory
dirfiles = Dir.entries(".")

# Loop through CSV files
dirfiles.each do |f| 
  if (/\.csv/i.match(f))
    puts "Found #{f}"   
    first = true
    headers = Hash.new 
    i = 0
    max = 0

    # Process CSV file
    CSV.foreach(f) do |row|
      
      # If we're first, remember the column names
      if first 
        row.each do |h|
          headers[h] = i
          i += 1
        end 
        first = false
      else
        # Process row
        # Loop through keys and build structure
        keys.each do |k|
          puts "SD:  #{schooldata[k]}"
          puts "VAL: #{row[headers[k].to_i]}"
        
          # Have we seen this key yet? and if so, is it in this row?
          #if (schooldata[k].to_s == "" && row[headers[k].to_i] != "")
          #  schooldata[k] = row[headers[k].to_i]
          #  puts "here"
          #end
        
          # Find the max depth we can make it to for this row
          if row[ headers[k].to_i ] != ""
            max += 1
            
            # Check to see if we need to add any info to this level
            if schooldata[k].to_s == ""
              schooldata[k] = row[headers[k].to_i]
            end
          end

        end
      end
      
    end

  end
end

puts schooldata.to_json



