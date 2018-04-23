require 'watir'
require 'nokogiri'
require_relative './proper_scrape_offline.rb'

# if you load a ruby file, all the constants get added to the global scope, so to set up our real time scrape we just load this file in irb

# Base Search Url, if you add a query string value it will direct us to the youtube search page for that string
BSU = 'https://www.youtube.com/results?search_query='
BR = Watir::Browser.new :firefox

# offline helper classes
QJ = QueryGenerator.new()
AR = Archivist.new()


# +-----------------------------------------------------------------------------+
#                             Scrape Helper Functions
# +-----------------------------------------------------------------------------+


# navigates the browser to the url representing the next search query
def next_page
  string = QJ.next_string()
  url = BSU + string
  BR.goto(url)
end

# returns an XML representation of the current page
def xml_page
  page = BR.html
  Nokogiri::HTML(page)
end

# saves all the video data on the current page to the database
def save_page
  page = xml_page()
  AR.save_all_videos(page)
end

# navigates to the next page and saves all the video data on it
def single_scrape
  next_page()
  save_page()
end

# executes 'num' scrapes in sequence
def scrape(num)
  num.times do
    single_scrape()
  end
end
