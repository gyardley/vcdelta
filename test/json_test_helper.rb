require 'sinatra/base'

class JsonServer < Sinatra::Base

  def self.base
    @base
  end

  def self.base=(str)
    @base = str
  end

  def self.boot
    instance = new
    Capybara::Server.new(instance).tap { |server| server.boot }
  end

  get '/json/:filename' do
    file = Rails.root.join('test', 'json', params[:filename]+'.json')
    data = file.read
    "#{data}"
  end

end