require 'net/http'
require 'mongo'
require 'rexml/document'
require 'pp'

def scraper
	mconnection = Mongo::Connection.new
	database = mconnection['rackspace_hack']
	coll = database['world_bank']
	coll.remove()

	uri = URI('http://api.worldbank.org/countries?per_page=1000')
	raw_data = Net::HTTP.get(uri)
	xml = REXML::Document.new(raw_data)

	xml.elements.each('wb:countries/wb:country') do |s|
		mongo_query = {}
		%w(wb:iso2Code wb:name wb:incomeLevel).each do |type|
			mongo_query[type.intern] = s.elements[type].text		
		end
		coll.insert(mongo_query)
	end
end

scraper
