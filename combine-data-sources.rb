require 'json'
require 'pp'

# path_to_1 - coordinates data source
# path_to_2 - information data source
def combine_sources(path_to_1, path_to_2, write_path)
	json_object_1 = JSON.parse( IO.binread(path_to_1) ) 
	json_object_2 = JSON.parse( IO.binread(path_to_2) ) 

	json_object_1['features'].each do |feature_country|
		json_object_2.each do |information_country|

			if feature_country['properties']['name'] == information_country['wb:name']
				feature_country['information'] = information_country	
				pp feature_country
			end

		end
	end		

	File.open(write_path, 'w') do |file|
		file.puts json_object_1.to_json
	end
end

combine_sources("libs/data/world-countries.json", "libs/data/world_names.json", "libs/data/world_names_combined.json")
