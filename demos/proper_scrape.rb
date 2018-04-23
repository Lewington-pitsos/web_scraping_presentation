# if you load a ruby file, all the constants get added to the global scope, so to set up our real time scrape we just load this file in irb
require 'watir'
require 'nokogiri'
require_relative './proper_scrape_offline.rb'
# Base Search Url, if you add a query string value it will direct us to the youtube search page for that string
=begin
BSU = 'https://www.youtube.com/results?search_query='
BR = Watir::Browser.new :firefox
BR.goto('https://www.youtube.com/watch?v=lUgosf8LufQ')
=end
QJ = QueryGenerator.new()

def visit_next_page
  string = QJ.next_string()
  url = BSU + string
  BR.goto(url)
end
