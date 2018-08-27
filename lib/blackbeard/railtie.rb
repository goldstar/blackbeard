module Blackbeard
  class Railtie < Rails::Railtie
    initializer "blackbeard.enable_request_store" do
      require 'request_store'

      def Blackbeard.store
        RequestStore.store
      end
    end
  end
end
