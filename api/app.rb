Dotenv.load
Bundler.require
Bundler.require(ENV['RACK_ENV']) if ENV['RACK_ENV']

$LOAD_PATH.unshift(File.expand_path('lib', __dir__))

LOG_DIR = File.expand_path('log', __dir__).freeze
FileUtils.mkdir_p(LOG_DIR)

require_relative 'app/controllers/application_controller'
require_relative 'app/models/application_record'

class App < Sinatra::Base
  register Sinatra::ActiveRecordExtension

  error_logger = ::File.new("#{LOG_DIR}/#{ENV['RACK_ENV']}-error.log", 'a+')
  error_logger.sync = true

  use AnswerController
  use AttachmentController
  use CommentController
  use IssueController
  use MemberController
  use NotificationController
  use NoticeController
  use ProblemController
  use ProblemGroupController
  use ScoreController
  use ScoreboardController
  use TeamController
  use ContestController

  configure do
    Time.zone = 'Tokyo'
    ActiveRecord::Base.default_timezone = :local

    enable :prefixed_redirects
    set :haml, { escape_html: false, format: :html5 }
    set :scss, style: :expanded

    # I18n.enforce_available_locales = false
    I18n.load_path = Dir[File.join(settings.root, 'locales', '*.yml')]
    I18n.backend.load_translations
    I18n.locale = :ja
  end

  helpers do
    def h(text)
      Rack::Utils.escape_html(text)
    end
  end

  options '*' do
    response.headers['Allow'] = 'HEAD,GET,PUT,PATCH,POST,DELETE,OPTIONS'
    response.headers['Access-Control-Allow-Headers'] = 'Accept, Authorization, Cache-Control, Content-Type'
    response.headers['Access-Control-Expose-Headers'] = 'X-Requested-With, X-HTTP-Method-Override, X-From'
    response.headers['Access-Control-Allow-Credentials'] = 'true'

    200
  end

  before do
    env['rack.errors'] = error_logger
  end

  not_found do
    if request.xhr?
      content_type :json
      { error: 'not found' }.to_json
    else
      'Not Found'
    end
  end
end
