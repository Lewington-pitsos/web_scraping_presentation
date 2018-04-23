require 'uri'

class QueryGenerator

  @@chars = [
    'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x','y', 'z', '>', '<', '(', ')', '1', '2', '3', '4', '5', '6', '7', '8', '9'
  ]

  def initialize(initial_string=0)
    self.query = [initial_string]
  end

  def next_string
    increment_char()
    query_string()
  end

  private

  attr_accessor :query

  def query_string
    # converts each ascii number in the array into the associated ascii character, then joins the query array into a string and returns ia url safe version of it
    URI.escape(query.map { |num| @@chars[num] }.join(''))
  end

  def increment_char(index=0)
    # if the current character has reached the final character, we reset it to the first character and increment the next character over
    # if there is no 'next character over' we reset all the charcters to the first character, return the current index to the first character and add an additional character to the end of the array
    # effectively we're just like, creating a base 80 or whatever numeric system
    if query[index]
      if query[index] == @@chars.length
        query[index] = 0
        increment_char(index + 1)
      else
        query[index] += 1
      end
    else
      add_new_character()
    end
  end

  def add_new_character
    # resets every character in the query array to the default starting character and adds an additional character (also deafult) to the array
    self.query = query.map { |_| 0 }
    query << 0
  end
end

=begin
q = QueryGenerator.new()

400.times do
  p q.next_string
end
=end
