class ApplicationHandler < ServiceHandler::Base
  before_rpc :authenticate_user

  attr_reader :req, :env

  def initialize(req, env)
    @req = req
    @env = env
  end

  def rpc_method
    env[:ruby_method].to_s
  end

  private

  def authenticate_user
    puts "you are authd up"
  end
end
