require "vidibus-service"

module Vidibus
  module Realm
    class Rack
      attr_reader :app, :env

      def initialize(app)
        puts "app: #{app.inspect}"
        @app = app
      end

      def call(env)
        puts "call triggered..."
        @env = env
        env[:realm] = realm
        puts "realm: #{env[:realm]}"
        app.call(env)
      end

      protected

      # Returns current subdomain which is, for now, the realm uuid itself.
      # The hostname must match the current service's domain because it may
      # contain several subdomains as well which are not suitable for
      # identifying the current realm.
      def subdomain
        puts "subdomain triggered..."
        puts "env: #{env.inspect}"
        puts "Server Name: #{env["SERVER_NAME"]}"
        env["SERVER_NAME"].match(/(.+)\.#{::Service.this.domain}/)
        $1
      rescue Vidibus::Service::ConfigurationError
        unless env['PATH_INFO'] == '/connector'
          raise(ServiceError, 'This service has not been configured yet')
        end
      end

      # Returns realm from constant or subdomain.
      def realm
        puts "realm triggered..."
        defined?(VIDIBUS_REALM) ? VIDIBUS_REALM : subdomain
      end
    end
  end
end
