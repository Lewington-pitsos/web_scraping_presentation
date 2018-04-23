require 'uri'
require 'nokogiri'
require 'yaml'

class QueryGenerator

  @@chars = [
    'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x','y', 'z', '>', '<', '(', ')', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y, 'Z'
  ]

  def initialize(initial_string=-1)
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

class Archivist

  # we first locate the video list and then find all it's children that match the video container selector (there are other elements outside the video list that match the video container selector that we want to avoid)
  @@video_selector = '#contents.ytd-item-section-renderer #dismissable.ytd-video-renderer'

  # there are some elements with the same class and id but no title that we want to avoid
  @@title_selector = '#video-title.ytd-video-renderer[title]'

  # the element containing the view data is actually the first child of the element selected with the @@views selector
  @@views_selector = '#metadata-line'

  @@decimal = '00'
  @@no_decimal = '000'

  def save_all_videos(xml_page)
    all_videos = []
    videos = xml_page.css(VIDEO)[1.. -1]
    videos.each do |video|
      title = video.css(TITLE)
      views = video.css(VIEWS)[0].first_element_child.text.strip
      view_number = to_integer(views)

      all_videos << {
        url: title.attribute('href').value.strip,
        views: view_number,
        title: title.text.strip
      }

    end
    add_to_database(all_videos)
  end

  private

  def to_integer(string)
    string = string.gsub('views', '')
    if string.include?('.')
      string = string.gsub('.', '')
      base = @@decimal
    else
      base = @@no_decimal
    end
    string.gsub(/[KMB]/, 'K' => base, 'M' => base + '000', 'B' => base + '00000').to_i
  end

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
