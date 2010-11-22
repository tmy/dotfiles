
def ri(*names)
  system(%{ri #{names.map {|name| name.to_s}.join(" ")}})
end

def refe(*names)
  system(%{refe #{names.map {|name| name.to_s}.join(" ")} | nkf -w})
end

require 'pp'
require 'rubygems'
require 'wirble'
#require 'scrapi'

# String#scrape
#class String
#  def scrape(pattern, options = {}, &block)
#    options = {:extract=>options} unless options.is_a?(Hash)
#    options[:parser_options] = {:char_encoding=>'utf8'}.merge(options[:parser_options]||{})
#    extract = options.delete(:extract) || block && :element || :text
#    scraped = Scraper.define do
#      process pattern, "matches[]"=>extract
#      result :matches
#    end.scrape(self, options) || []
#    block ? scraped.map{|i| block.call(i)} : scraped
#  end
#end


Wirble.init
Wirble.colorize

def self.all_classes
  a = []
  ObjectSpace.each_object(Class){|obj| a << obj.name}
  a
end
