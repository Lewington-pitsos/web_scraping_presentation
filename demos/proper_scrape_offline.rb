require 'uri'
require 'nokogiri'
require 'yaml'

# just (exhaustively) generates and returns unique strings made up of youtube search compatible characters
class QueryGenerator

  # basically a list of youtube-search-compatible characters (simpler than converting straight from the ascii table and having lots of conditions to weed out incompatible chars)
  @@chars = [
    'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x','y', 'z', '>', '<', '(', ')', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'
  ]

  def initialize(initial_string=-1)
    self.query = [initial_string]
  end

  # returns the next string
  def next_string
    increment_char()
    query_string()
  end

  private

  attr_accessor :query

  # converts the current string representation (made of numbers) to an actual string
  def query_string
    # converts each ascii number in the array into the associated ascii character, then joins the query array into a string and returns ia url safe version of it
    URI.escape(query.map { |num| @@chars[num] }.join(''))
  end

  # changes the current string to the next unique string up
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


# in charge of reading in data from an XML representation of a page and saving the data of the videos on that page to the database
class Archivist

  # we first locate the video list and then find all it's children that match the video container selector (there are other elements outside the video list that match the video container selector that we want to avoid)
  @@video_selector = '#contents.ytd-item-section-renderer #dismissable.ytd-video-renderer'

  # there are some elements with the same class and id but no title that we want to avoid
  @@title_selector = '#video-title.ytd-video-renderer[title]'

  # the element containing the view data is actually the first child of the element selected with the @@views selector
  @@views_selector = '#metadata-line'

  @@decimal = '00'
  @@no_decimal = '000'

  # INPUT: a Nokogiri::XML object representing the current page
  # DOES: gets the data for all the videos on the current page and saves it all to the database
  # OUTPUT: N/A
  def save_all_videos(xml_page)

    # first we grab all the nokogiri objects representing videos on the current page
    # then we search each for it's title, title url and view number
    # we save each of these to an object which is added to an array
    # after all videos have had their data added to this array we save the whole array to the database

    all_videos = []
    videos = xml_page.css(@@video_selector)

    videos.each do |video|

      title =         video.css(@@title_selector)
      views =         video.css(@@views_selector)[0].first_element_child.text.strip
      view_number =   to_integer(views)

      all_videos << {
        url:    title.attribute('href').value.strip,
        views:  view_number,
        title:  title.text.strip
      }

    end

    add_to_database(all_videos)
  end

  private

  # INPUT: a string representing the number of views for a video
  # DOES: strips the chaff from the string and converts the number-letter numbering to pure numbers, then converts it to an int
  # OUTPUT: the integer representing the same number
  def to_integer(string)
    # first we strip the chaff
    string = string.gsub('views', '')

    # if the string includes a decimal point we need to remove it
    # we also need to change the conversion of letters => zeros to reflect the fact that some digits were behind the decimal point (for youtube it is only ever one)
    if string.include?('.')
      string = string.gsub('.', '')
      base = @@decimal
    else
      base = @@no_decimal
    end

    # finally we convert the letter to a numeric value and return the resulting string as an integer
    string.gsub(/[KMB]/, 'K' => base, 'M' => base + '000', 'B' => base + '00000').to_i
  end

  # INPUT: an array representing the data from a number of videos
  # DOES: appends that data to the end of a yaml file already contaning a similar array
  # OUTPUT: N/A
  def add_to_database(array)
    data = YAML::load_file('./demos/database/test.yaml') || []
    new_data = array.concat(data)
    File.open('./demos/database/test.yaml', 'w') { |f| f.write new_data.to_yaml }
  end
end


=begin
q = QueryGenerator.new()

400.times do
  p q.next_string
end


doc = File.open('./demos/example_page.html') { |f| Nokogiri::HTML(f) }

ar = Archivist.new()

ar.all_videos(doc)


p ar.send(:to_integer, '0.9K views')
=end
