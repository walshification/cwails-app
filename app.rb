# Create the database context
db_config_file = File.join(File.dirname(__FILE__), "app", "database.yml")
if File.exist?(db_config_file)
  config = YAML.load(File.read(db_config_file))
  DB = Sequel.connect(config)
  Sequel.extension :migration
end

# Connect all our framework's classes
Dir[File.join(File.dirname(__FILE__), 'lib', '*.rb')].each {|file| require file }

# Connect all our framework's files
Dir[File.join(File.dirname(__FILE__), 'app', '**', '*.rb')].each {|file| require file }

# If there is a database connection, run all the migrations
if DB
  Sequel::Migrator.run(DB, File.join(File.dirname(__FILE__), 'app', 'db', 'migrations'))
end

require 'yaml'

ROUTES = YAML.load(File.read(File.join(File.dirname(__FILE__), "app", "routes.yml")))

require "./lib/router"

class App
  attr_reader :router

  def initialize
    @router = Router.new(ROUTES)
  end

  def self.root
    File.dirname(__FILE__)
  end

  def call(env)
    result = router.resolve(env)
    [result.status, result.headers, result.content]
  end
end
