class ApplicationHandler < ActionHandler::Base
  before_action :authenticate_user

  attr_reader :req, :env

  def initialize(req, env)
    @req = req
    @env = env
  end

  def action_name
    env[:ruby_method].to_s
  end

  private

  def authenticate_user
    puts "you are authd up"
  end
end
