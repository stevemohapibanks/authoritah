ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/railsenv/config/environment")
require 'spec'
require 'spec/rails'
 
Spec::Runner.configure do |config|
  config.use_transactional_fixtures = true
  config.use_instantiated_fixtures  = false
  config.mock_with :mocha
end
 
plugin_spec_dir = File.dirname(__FILE__)
ActiveRecord::Base.logger = Logger.new(plugin_spec_dir + "/debug.log")
 
dir = File.expand_path(File.dirname(__FILE__))
require "#{dir}/../lib/authoritah"

class TestAuthorizerController < ActionController::Base
  
  def index
    render
  end
  
  def create
    redirect_to '/success'
  end
  
  def show
    render
  end

end

class SpecialisedTestAuthorizerController < TestAuthorizerController
end
