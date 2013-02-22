# createJSON.rb
# Ben Garvey
# ben@bengarvey.com
# @bengarvey
# 2/9/2013
# Description:  Generates a JSON file for the Philadelphia education data based on school code.  It's needed to create a hierarchy from the flat CSV files.

require 'csv'
require 'json'


# Node class for our tree
class Node
  
  attr_accessor :children, :groupname, :groupvalue, :data
  
  def set(name, value)
    @data[name] = value
  end

  def get(name)
    return @data[name]
  end

  def empty?
    if @data.count == 0 && @children.count == 0
      return true
    else
      return false
    end

  end

  def to_json(depth)
 
    j = ""
 
    i = 0
    tab = "\t"
    while i<depth
      tab += "\t"
      i += 1
    end

    if @children.count > 0
      j += "#{tab}{\n"
      j += "#{tab}#{groupname.to_json} : #{groupvalue.to_json},\n"
     # j += "#{tab}\"depth\" : #{depth.to_s.to_json},\n"
      j += "#{tab}\"children\" : [\n"

      @children.each do |c|
        if !c.empty?
          j += "#{c.to_json(depth + 1)}#{tab},\n"
        end
      end

      j = j.chomp(",\n") + "\n"

      j += "#{tab}]\n#{tab}}\n"
    else
      j = "#{tab}{\n"
      @data.each do |k, v|
        j += "#{tab}#{k.to_json} : #{v.to_json},\n"
      end
      j = j.chomp(",\n") + "\n"
      j += "#{tab}},\n"
    end

    j = j.chomp(",\n") + "\n"

    return j
  end
 
  def initialize
    @children   = Array.new
    @data       = Hash.new
    @groupvalue = ""
    @groupname  = ""
  end
end

# Holder class for our nodes
class District

  # Accepts an array of data and inserts it into the data structure
  def processRow(row)

    # Creating the node objext
    n = Node.new

    # Set the data for the node
    row.each_with_index do |val, i|
      n.set(@header[i], val)
    end

    # Add node to the tree structure
    add(n)
    
    #puts to_json(0)
    #gets

    #gets()
  end

  def add(node)
    #gets 
    found   = false
    current = @data    
    depth   = 0
    count = 0
    #puts "Current:  #{current.groupvalue}"
    # Traverse the tree
    while (!found)

      #current.groupname = @keys[depth]

      #puts "Depth:  #{depth}"
      #puts "Group:  #{current.groupname}"     
 
      # Have we found a childless node, but below max depth?
      if (current.children.count == 0 && depth <= @keys.count)
        #puts "No kids, below depth #{depth} vs #{@keys.count}"

        # Set the group for this depth and move down
        #current.groupvalue = node.get(@keys[depth])
        #current.groupname  = @keys[depth]
       
        if depth == @keys.count
            current.children.push(node)
          #puts "LOOK 1"
          found = true
        else 
          # Generate a new child node
          n             = Node.new
          n.groupvalue = node.get(@keys[depth])
          n.groupname = @keys[depth]
          count += 1
          #puts "C:  #{count} #{depth} -> #{@keys[depth]} #{n.groupname}"
          #gets
          # Connect it to the tree
          current.children.push(n)
          #puts "LOOK 2"

          # Make n the new current node
          current = n

        end

        depth += 1

      elsif depth > @keys.count  # Have we reached max depth?
        #puts "Max depth"

        # Connect it to the tree

        if node.children.count > 0
          current.children.push(node.children)
        end
        #puts "LOOK 3"
        found = true
      else # Check to see if we match up with any of these child nodes
        #puts "Checking for a match"
        # Get child nodes
        kids = current.children
        foundit = false

        kids.each do |k| 

          # Do we match this path?
          #puts "#{k.groupvalue} vs #{node.get(k.groupname)}"
          if k.groupvalue == node.get(k.groupname)
            #puts "Found a match"
            #gets
            # Move down the tree
            current = k
            foundit = true
            depth += 1
          end
        
        end 
        
        # If we didn't find it, add a new group node
        if (!foundit)
          #puts "Didn't find a match, adding this node"
          n = Node.new
          n.groupvalue = node.get(@keys[depth])
          n.groupname = @keys[depth]
          current.children.push(n)
          #puts "LOOK 4"
          current = n
          depth += 1 
          count += 1
        end
      end
    end
  end

  def printData
    puts @data
  end

  def to_json(depth)
    return @data.to_json(depth)
  end

  # Check to see if this key matches
  def checkKey(key, data)
    @data.each_with_index do |val, i|
      #puts "#{val} - #{i}"
    end
  end

  # This will determine our hierarchy.  Send in the primary key first, secondary second, etc.
  def addKey(x)
    @keys.push(x)
  end

  # Accepts the first row of data from the data set so when we process rows, we will understand the column names
  def setHeader(row)
    i = 0
    
    # We'll need to access the header names later 
    row.each do |r|
      @header[i] = r
      i += 1  
    end
    
  end


  def initialize
    @header = Hash.new
    @keys   = Array.new
    @data   = Node.new
    @data.groupname = "Main"
    @data.groupvalue = ""
    
    # Make a sub node to seed the tree
    s = Node.new
    #@data.children.push(s)
  end

end

d = District.new
d.addKey('SCHOOL_CODE');
d.addKey('SCHOOL_YEAR');

# Find all the CSV files in this directory
dirfiles = Dir.entries('./data/')


count = 0

# Loop through CSV files
dirfiles.each do |f| 
  if (/\.csv/i.match(f))
    puts "Found #{f}"   
    first = true
    f = "data/#{f}"

    # Process CSV file
    CSV.foreach(f) do |row|
      
      r = Hash.new
      j = 0
      # If we're first, remember the column names
      if first 
        d.setHeader(row)
        first = false
      else
        puts "Processing row #{count}"
        d.processRow(row)
        count += 1
      end

    end
  end
end

File.open("all.json", 'w') { |file| file.write(d.to_json(0)) }
