require "vidibus-service"

module Vidibus
  module Realm
    class Rack
      attr_reader :app, :env

      def initialize(app)
        @app = app
      end

      def call(env)
        @env = env
        env[:realm] = realm
        app.call(env)
      end

      protected

      # Returns current subdomain which is, for now, the realm uuid itself.
      # The hostname must match the current service's domain because it may
      # contain several subdomains as well which are not suitable for
      # identifying the current realm.
      def subdomain
        server_name.match(/(.+)[\.-]{1}#{::Service.this.domain}/)
        $1
      rescue Vidibus::Service::ConfigurationError
        unless env['PATH_INFO'] == '/connector'
          raise(ServiceError, 'This service has not been configured yet')
        end
      end

      # Returns realm from constant or subdomain.
      def realm
        defined?(VIDIBUS_REALM) ? VIDIBUS_REALM : subdomain
      end

      private

      def server_name
        request = ::Rack::Request.new(env)
        request.host_with_port
      end
    end
  end
end
