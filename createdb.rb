# Set up for the application and database. DO NOT CHANGE. #############################
require "sequel"                                                                      #
connection_string = ENV['DATABASE_URL'] || "sqlite://#{Dir.pwd}/development.sqlite3"  #
DB = Sequel.connect(connection_string)                                                #
#######################################################################################

# Database schema - this should reflect your domain model
DB.create_table! :wineries do
  primary_key :id
  String :title
  String :description, text: true
  String :favorite wine
  String :location
end
DB.create_table! :reviews do
  primary_key :id
  foreign_key :winery_id
  Boolean :most recent
  String :name
  String :date
  String :comments, text: true
end

# Insert initial (seed) data
wineries_table = DB.from(:wineries)

wineries_table.insert(title: "Jessup Cellars", 
                    description: "The Jessup Cellars story is one of passion, family, hard work, resilience and, of course, fantastic wine. Over the past two decades, Jessup Cellars has earned a loyal following for their ultra-premium wines of distinction and a word-of-mouth reputation for hosting one of the friendliest tasting rooms in all of wine county.",
                    favorite wine: "Manny's Blend",
                    location: "Yountville, CA")

wineries_table.insert(title: "Far Niente", 
                    description: "Far Niente's Estate Bottled Cabernet Sauvignon combines their noble vineyards in Oakville with their passion and commitment to making the very best wine possible.",
                    favorite wine: "En Route Pinot Noir",
                    location: "Oakville, CA")

wineries_table.insert(title: "Pence", 
                    description: "In the classical tradition, their wines are intended to be directly representative of their terroir",
                    favorite wine: "Pinot Noir",
                    location: "Sta. Rita Hills, CA")