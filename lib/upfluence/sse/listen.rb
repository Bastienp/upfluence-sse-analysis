require 'net/http'
require 'observer'
require 'singleton'

module Upfluence
  module Sse
    class Listen
      include Observable
      include Singleton

      def initialize
        listen
      end

      private

      def listen
        uri               = URI('https://stream.upfluence.co/stream')
        request           = Net::HTTP::Get.new uri
        request['Accept'] = 'text/event-stream'
        http              = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl      = true

        Thread.new do
          http.request request do |response|
            response.read_body do |chunk|
              chunk.force_encoding('utf-8').split("\n").each do |line|
                changed
                notify_observers(line)
              end
            end
          end
        end
      end
    end
  end
end
