class ConfigController < ApplicationController
  before '/api/config*' do
    I18n.locale = :en if request.xhr?
    halt 404 unless is_admin?
  end

  get '/api/configs' do
    json Config.readables(user: current_user)
  end

  post '/api/configs' do
    halt 403 unless Config.allowed_to_create_by?(current_user)

    @config = Config.new(params_to_attributes_of(klass: Config))

    if @config.save
      status 201
      headers 'Location' => to("/api/configs/#{@config.id}")
      json @config
    else
      status 400
      json @config.errors
    end
  end

  before '/api/configs/:id' do
    @config = Config.find(params[:id])
    halt 404 unless @config&.allowed?(by: current_user, method: request.request_method)
  end

  get '/api/configs/:id' do
    json @config
  end

  update_block = proc do
    if request.put? and not filled_all_attributes_of?(klass: Config)
      status 400
      next json required: insufficient_attribute_names_of(klass: Config)
    end

    @config.attributes = params_to_attributes_of(klass: Config)

    unless @config.valid?
      status 400
      next json @config.errors
    end

    if @config.save
      json @config
    else
      status 400
      json @config.errors
    end
  end

  put '/api/configs/:id', &update_block
  patch '/api/configs/:id', &update_block

  delete '/api/configs/:id' do
    if @config.destroy
      status 204
    else
      status 500
    end
  end
end
