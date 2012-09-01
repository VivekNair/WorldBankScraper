require 'net/http'
require 'mongo'
require 'pp'
require 'rexml/document'

def mine_gdp
	mconnection = Mongo::Connection.new
	database = mconnection['rackspace_hack']
	coll = database['world_bank']
	insert_coll = database['world_bank_gdp']
	
	iso_values = []
	coll.find do |cursor|
		cursor.each { |country| iso_values << country['wb:iso2Code'] }
	end

	iso_uris = iso_values.map { |iso| URI("http://api.worldbank.org/countries/#{iso}/indicators/NY.GDP.MKTP.CD") }
	
	mongo_query = {}
	iso_uris.map do |iso_uri|
		raw_data = Net::HTTP.get(iso_uri)
		xml = REXML::Document.new(raw_data)

		xml.elements.each('wb:data/wb:data') do |s|
			mongo_query = {}
			mongo_query  = { "wb:iso"	: 
			%w(wb:indicator wb:country wb:date wb:value wb:decimal).each do |type|
				mongo_query[type.intern] = s.elements[type].text		
			end
			insert_coll.insert(mongo_query)
		end
	
	end
end

mine_gdp
