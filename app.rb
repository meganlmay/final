# Set up for the application and database. DO NOT CHANGE. #############################
require "sinatra"    
require "sinatra/cookies"                                                                   #
require "sinatra/reloader" if development?                                            #
require "sequel"                                                                      #
require "logger"                                                                      #
require "twilio-ruby"                                                                 #
require "bcrypt" 
require "geocode"                                                                     #
connection_string = ENV['DATABASE_URL'] || "sqlite://#{Dir.pwd}/development.sqlite3"  #
DB ||= Sequel.connect(connection_string)                                              #
DB.loggers << Logger.new($stdout) unless DB.loggers.size > 0                          #
def view(template); erb template.to_sym; end                                          #
use Rack::Session::Cookie, key: 'rack.session', path: '/', secret: 'secret'           #
before { puts; puts "--------------- NEW REQUEST ---------------"; puts }             #
after { puts; }                                                                       #
#######################################################################################

wineries_table = DB.from(:wineries)
reviews_table = DB.from(:reviews)

wineries_table = DB.from(:wineries)
reviews_table = DB.from(:reviews)
users_table = DB.from(:users)

before do
    @current_user = users_table.where(id: session["user_id"]).to_a[0]
end

get "/" do
    puts wineries_table.all
    @wineries = wineries_table.all.to_a
    view "wineries"
end

get "/wineries/:id" do
    @winery = wineries_table.where(id: params[:id]).to_a[0]
    @reviews = reviews_table.where(event_id: @wineries[:id])
    @reviews_count = reviews_table.where(event_id: @wineries[:id], yes: true).count
    @users_table = users_table
    view "winery"
end

get "wineries/:id/location" do
    results = Geocoder.search(params["q"])
    @lat_long = results.first.coordinates # => [lat, long]
    @location = results.first.city

    # Define the lat and long
    @lat = "#{@lat_long [0]}"
    @long = "#{@lat_long [1]}"
    src= “https://www.google.com/maps/embed/v1/place?key=AIzaSyCtovsQvkIUWlNqtYwXY87gEd4ZSmJEhMw=<%= @lat_long %>&zoom=6” allowfullscreen>
end 

get "/wineries/:id/reviews/new" do
    @winery = wineries_table.where(id: params[:id]).to_a[0]
    view "new_reviews"
end

get "/wineries/:id/reviews/create" do
    puts params
    @winery = wineries_table.where(id: params["id"]).to_a[0]
    reviews_table.insert(event_id: params["id"],
                       user_id: session["user_id"],
                       review: params["yes"],
                       comments: params["comments"])
    view "create_reviews"
end

get "/users/new" do
    view "new_user"
end

post "/users/create" do
    puts params
    hashed_password = BCrypt::Password.create(params["password"])
    users_table.insert(name: params["name"], email: params["email"], password: hashed_password)
    view "create_user"
end

get "/logins/new" do
    view "new_login"
end

post "/logins/create" do
    user = users_table.where(email: params["email"]).to_a[0]
    puts BCrypt::Password::new(user[:password])
    if user && BCrypt::Password::new(user[:password]) == params["password"]
        session["user_id"] = user[:id]
        @current_user = user
        view "create_login"
    else
        view "create_login_failed"
    end
end

get "/logout" do
    session["user_id"] = nil
    @current_user = nil
    view "logout"
end
