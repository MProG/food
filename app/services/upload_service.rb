require 'net/http'

class UploadService
  API_KEY = "MAdy5P4GGA0dZnsy2Tgzvgby09YyDhNo2UkXL4BG"
  VALUES_BY_PAGE = 500
  NUTRIENTS_VALUES_BY_PAGE = 1500
  UPC_SPLITTER = ", UPC: "

  def get_all_product_names
    data = collect_data('f')
    create_csv_food(data)
  end

  def get_all_nutrients_names
    data = collect_data('n')
    create_csv_nutrient(data)
  end

  def get_food_data(food)
    data = make_request(food_path(food.dnbo))
    return false unless data["report"]
    add_food_to_csv(data["report"]["food"], food)
  end

  private

  def collect_data(product_type)
    data = []
    page = 0
    
    while true
      url_string = list_path(product_type, page)
      step = make_request(url_string)["list"]["item"]
      break if step.empty?
      data += step
      page += 1
    end
    data
  end

  def make_request(url_string)
    url = URI.parse(url_string)
    JSON.parse(Net::HTTP.get(url))
  end

  def list_path(field_name, page)
    "https://api.nal.usda.gov/ndb/list?format=json&lt=#{field_name}&sort=id&max=#{VALUES_BY_PAGE}&offset=#{VALUES_BY_PAGE*page}&api_key=#{API_KEY}"
  end

  def food_path(food_id)
    "https://api.nal.usda.gov/ndb/reports/?ndbno=#{food_id}&type=b&format=json&api_key=#{API_KEY}"
  end

  # https://api.nal.usda.gov/ndb/reports/?ndbno=45010022&type=b&format=json&api_key=MAdy5P4GGA0dZnsy2Tgzvgby09YyDhNo2UkXL4BG

  def create_csv_food(data)
    attributes = %w{food_id name upc}

    CSV.open("foods.csv", "wb") do |csv|
      csv << attributes

      data.each do |food|

        food_name, food_upc = food["name"].split(UPC_SPLITTER)
        csv << [food["id"], food_name, food_upc] if food_upc.present? || food["id"].length > "09514".length
      end
    end
  end

  def create_csv_nutrient(data)
    attributes = %w{nutrient_id name}

    CSV.open("nutrients.csv", "wb") do |csv|
      csv << attributes

      data.each do |food|
        csv << [food["id"], food["name"]]
      end
    end
  end

  def add_food_to_csv(data, food)
    nutrients_ndbo = Nutrient.all.map(&:dnbo)

    attributes = %w{ndbno name upc ru} + nutrients_ndbo
    file_name = "product_#{Date.today.to_s}.csv"
    new_file = File.file?(file_name)

    CSV.open(file_name, "a+") do |csv|
      csv << attributes unless new_file
      nutriends_values = Array.new(Nutrient.count, '')

      data["nutrients"].each do |el|
        nutrient_index = nutrients_ndbo.index(el['nutrient_id'])
        nutriends_values[nutrient_index] = "#{el['value']}~#{el['unit']}"
      end

      csv << [food.dnbo, food.name, food.upc, data['ru']] + nutriends_values
    end

    portion_new_file = File.file?('portions.csv')
    CSV.open("portions.csv", "a+") do |csv|
      csv << %w{ndbno name upc ru portion_label eqv eunit qty} unless portion_new_file

      portions_el = data["nutrients"].first["measures"][0]
      portion_array = [portions_el["label"], portions_el["eqv"], portions_el["eunit"], portions_el["qty"]]

      csv << [food.dnbo, food.name, food.upc, data['ru']] + portion_array
    end
  end
end

