require 'zuora'
require 'csv'

client = Zuora::Client.new("zuora.sfdc@tripadvisor.com", "Am3ndPr0c6", "https://www.zuora.com")
client.show_logs = false
client.login
results = client.query("Select id, ratePlanId from rateplancharge where PriceChangeOption != 'NoChange'")
rate_plan_charge_ids = Array.new
results.records.each do |record|
  rate_plan_charge_ids.push record.id
end

file = File.open("rate_plan_charges_to_update.csv", "w")
num_rows = 0
while rate_plan_charge_ids.size > 0
  puts "******** charge id size: #{rate_plan_charge_ids.size}"
  batch = rate_plan_charge_ids.shift(100)
  where_clause = batch.map do |id|
    "Id = '#{id}'"
  end.join(" OR ")

  puts where_clause

  temp_file = Tempfile.new("rpc_query")
  client.export("Select Id from rateplancharge where Subscription.Status = 'Active' and (#{where_clause})", temp_file)
  puts temp_file.class
  puts temp_file

  CSV.foreach(temp_file.path, headers: true, return_headers: true ) do |data|
    unless data.header_row? 
      num_rows += 1
      file.puts(data)
    end
  end

end
file.close
puts "number of rows in file: #{num_rows}"