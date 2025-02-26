class ApplicationController < Sinatra::Base
  set :default_content_type, 'application/json'
  
  # Add your routes here
  get "/listings" do
    Listing.all.to_json(include: { reviews: { include: :user } })
  end

  get "/listings/climate/:climate_type" do 
    Listing.where(climate_type: params[:climate_type]).to_json(include: { reviews: { include: :user } })
  end

  get "/users" do 
    User.all.to_json
  end

  get "/account/:id" do 
    Owner.find(params[:id]).to_json(include: :listings)
  end

  get "/users/:id" do 
    User.find(params[:id]).to_json(include: :listings)
  end

  post "/accounts/authenticateowner" do
    match = Owner.auth_user? params[:user], params[:password]
    if match
      match.to_json(include: :listings)
    else
      halt 500
    end
  end

  post "/accounts/authenticateuser" do
    match = User.auth_user? params[:user], params[:password]
    if match
      match.to_json(include: { reviews: { include: :listing}})
    else
      halt 500
    end
  end

  patch "/review/:id" do
    review = Review.find(params[:id])
    review.update(comment: params[:comment])
    review.update(rating: params[:rating])
    listing = review.listing
    listing.to_json(include: { reviews: { include: :user } })
  end

  patch "/listings/:id" do 
    listing = Listing.find(params[:id])
    listing.update(description: params[:description])
    listing.to_json
  end

  post "/listings" do 
    listing = Listing.create(
      title: params[:title],
      location: params[:location],
      description: params[:description],
      price_per_day: params[:price_per_day],
      climate_type: params[:climate_type],
      thumbnail: params[:thumbnail],
      owner_id: params[:owner_id]
    )
    listing.to_json
  end

  delete "/listings/:id" do 
  
    listing = Listing.find(params[:id])
    listing.destroy

    listing.to_json
  end

end