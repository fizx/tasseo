require 'sinatra'
require 'rack-ssl-enforcer'
require 'haml'

module Tasseo
  class Application < Sinatra::Base

    configure do
      enable :logging
      mime_type :js, 'text/javascript'
      use Rack::SslEnforcer if ENV['FORCE_HTTPS']
    end

    before do
      find_dashboards
    end

    helpers do
      def find_dashboards
        @dashboards = []
        Dir.foreach("public/d").grep(/\.js/).sort.each do |f|
          @dashboards.push(f.split(".").first)
        end
      end
    end

    get '/' do
      if !@dashboards.empty?
        haml :index, :locals => {
          :dashboard => nil,
          :list => @dashboards,
          :error => nil
        }
      else
        haml :index, :locals => {
          :dashboard => nil,
          :list => nil,
          :error => 'No dashboard files found.'
        }
      end
    end

    get %r{/([\S]+)} do
      path = params[:captures].first
      if @dashboards.include?(path)
        haml :index, :locals => { :dashboard => path }
      else
        haml :index, :locals => {
          :dashboard => nil,
          :list => @dashboards,
          :error => 'That dashboard does not exist.'
        }
      end
    end

  end
end

