# Set up for the application and database. DO NOT CHANGE. #############################
require "sequel"                                                                      #
connection_string = ENV['DATABASE_URL'] || "sqlite://#{Dir.pwd}/development.sqlite3"  #
DB = Sequel.connect(connection_string)                                                #
#######################################################################################

# Database schema - this should reflect your domain model
DB.create_table! :events do
  primary_key :id
  String :title
  String :description, text: true
  String :date
  String :location
end
DB.create_table! :rsvps do
  primary_key :id
  foreign_key :event_id
  foreign_key :user_id
  Boolean :going
  String :comments, text: true
end
DB.create_table! :users do
  primary_key :id
  String :name
  String :email
  String :password
end

# Insert initial (seed) data
events_table = DB.from(:events)

events_table.insert(title: "Jessup Cellars Tasting", 
                    description: "The Jessup Cellars story is one of passion, family, hard work, resilience and, of course, fantastic wine. Over the past two decades, Jessup Cellars has earned a loyal following for their ultra-premium wines of distinction and a word-of-mouth reputation for hosting one of the friendliest tasting rooms in all of wine county.",
                    date: "May 18",
                    location: "6740 Washington Street Yountville, CA 94599")

events_table.insert(title: "Far Niente Tasting", 
                    description: "Far Niente's Estate Bottled Cabernet Sauvignon combines their noble vineyards in Oakville with their passion and commitment to making the very best wine possible.",
                    date: "June 21",
                    location: "1350 Acacia Drive Oakville, CA 94562")

events_table.insert(title: "Pence Tasting", 
                    description: "In the classical tradition, their wines are intended to be directly representative of their terroir",
                    date: "July 29",
                    location: "1909 West Highway 246 Sta. Rita Hills, CA 93427")