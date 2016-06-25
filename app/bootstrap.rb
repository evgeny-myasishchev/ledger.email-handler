require 'app/lib/services'

class Bootstrap
  attr_reader :app_root
  def initialize(app_root = Dir.pwd)
    @app_root = Pathname.new app_root
  end

  def create_services
    Services.new @app_root.join('.data')
  end
end
