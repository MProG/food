require 'net/http'

class UploadService
  API_KEY = "MAdy5P4GGA0dZnsy2Tgzvgby09YyDhNo2UkXL4BG"
  VALUES_BY_PAGE = 500
  NUTRIENTS_VALUES_BY_PAGE = 1500
  UPC_SPLITTER = ", UPC: "

  def get_all_product_names
    data = []
    page = 0
    
    while true
      step = make_food_list_request(page)["list"]["item"]
      break if step.empty?
      data += step
      page += 1
    end
    create_csv_food(data)
  end

  def get_all_nutrients_names
    data = []
    page = 0
    
    while true
      step = make_nutrient_list_request(page)["list"]["item"]
      break if step.empty?
      data += step
      page += 1
    end
    create_csv_nutrient(data)
  end

  def nutrient_food_by_id(id)
    data = []
    page = 0
    
    while true
      step = nutrient_food_list_request(page, id)["report"]["foods"]
      break if step.empty?
      data += step
      page += 1
    end
    
    nutrient_csv(data, id)
  end


  private

  def make_food_list_request(page)
    url_string = "https://api.nal.usda.gov/ndb/list?format=json&lt=f&sort=n&max=#{VALUES_BY_PAGE}&offset=#{VALUES_BY_PAGE*page}&api_key=#{API_KEY}"
    url = URI.parse(url_string)
    result = JSON.parse(Net::HTTP.get(url))
  end

  def make_nutrient_list_request(page)
    url_string = "https://api.nal.usda.gov/ndb/list?format=json&lt=n&sort=n&max=#{VALUES_BY_PAGE}&offset=#{VALUES_BY_PAGE*page}&api_key=#{API_KEY}"
    url = URI.parse(url_string)
    result = JSON.parse(Net::HTTP.get(url))
  end

  def nutrient_food_list_request(page, id)
    url_string = "https://api.nal.usda.gov/ndb/nutrients/?format=json&api_key=#{API_KEY}&nutrients=#{id}&max=#{NUTRIENTS_VALUES_BY_PAGE}&offset=#{NUTRIENTS_VALUES_BY_PAGE*page}"
    url = URI.parse(url_string)
    result = JSON.parse(Net::HTTP.get(url))
  end



  def create_csv_food(data)
    attributes = %w{food_id name upc}

    CSV.open("foods.csv", "wb") do |csv|
      csv << attributes

      data.each do |food|
        food_name, food_upc = food.split(UPC_SPLITTER)
        csv << [food["id"], food_name, upc]
      end
    end
  end

  def create_csv_nutrient(data)
    attributes = %w{nutrient_id name}

    CSV.open("nutrients.csv", "wb") do |csv|
      csv << attributes

      data.sort{|x,y| x["id"].to_i <=> y["id"].to_i }.each do |food|
        csv << [food["id"], food["name"]]
      end
    end
  end

  def nutrient_csv(data, id)
    attributes = %w{nutrient_id m_100 ndbno weight measure unit value}

    CSV.open("nutrient_#{id}.csv", "wb") do |csv|
      csv << attributes

      data.each do |food|
        nutrient = food["nutrients"][0]
        csv << [id, nutrient["gm"], food["ndbno"], food["weight"], food["measure"], nutrient["unit"], nutrient["value"]]
      end
    end
  end
end

