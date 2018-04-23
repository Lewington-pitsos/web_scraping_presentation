# if you load a ruby file, all the constants get added to the global scope, so to set up our real time scrape we just load this file in irb
require 'watir'
require 'nokogiri'
require_relative './proper_scrape_offline.rb'
# Base Search Url, if you add a query string value it will direct us to the youtube search page for that string

BSU = 'https://www.youtube.com/results?search_query='
BR = Watir::Browser.new :firefox

QJ = QueryGenerator.new()

VIDEO = '#dismissable.ytd-video-renderer' # first one is blank

TITLE = '#video-title.ytd-video-renderer[title]' #id, not class
# the url is the href of this element
VIEWS = '#metadata-line' # the first child of this element

def next_page
  string = QJ.next_string()
  url = BSU + string
  BR.goto(url)
end

def xml_page
  page = BR.html
  Nokogiri::HTML(page)
end
