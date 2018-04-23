require 'net/http'

# Uniform Resource Identifier. Basicaly the equivelent of a memory address for a thing on the internet.

uri = URI('https://en.wikipedia.org/wiki/Steven_Universe')

p uri.scheme
p uri.host
p uri.path

page = Net::HTTP.get(uri)
p page
