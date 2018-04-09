require 'net/http'
require 'watir'

uri = URI('https://www.google.com.au')


def time(arg, &block)
  start = Time.new
  yield arg
  finish = Time.new
  p finish - start
end

time(uri) do |uri|
  Net::HTTP.get(uri)
end

# time('https://www.google.com.au') do |uri|
#   br = Watir::Browser.new :firefox, headless: true
#   br.goto(uri)
# end
