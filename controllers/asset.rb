class AssetRoutes < Sinatra::Base
  get "/css/*" do
    file_name = params[:splat].first
    views =  Pathname(settings.views) + "../../views"

    puts views

    if File.exists?(views + "css" + file_name)
      send_file views + "css" + file_name
    elsif File.exists?(views + "scss" + file_name.sub(%r{.css$}, ".scss"))
      scss :"scss/#{file_name.sub(%r{.css$}, "")}"
    else
      halt 404
    end
  end

  get "/js/*.js" do
    file_name = params[:splat].first
    views =  Pathname(settings.views) + "../../views"

    if File.exists?(views + "js" + "#{file_name}.js")
      send_file views + "js" + "#{file_name}.js"
    else
      halt 404
    end
  end
end
