module TaxCloud #:nodoc:
  # A <tt>Client</tt> communicates with the TaxCloud service.
  class Client < Savon::Client
    # Create a new client.
    def initialize
      super client_params
    end

    # Make a safe SOAP call.
    # Will raise a TaxCloud::Errors::SoapError on error.
    #
    # === Parameters
    # [method] SOAP method.
    # [body] Body content.
    def call(method, message = {})
      safe do
        super method, message: message.merge(auth_params)
      end
    end

    def request(method, message = {})
      call method, message
    end

    # Ping the TaxCloud service.
    #
    # Returns "OK" or raises an error if the TaxCloud service is unreachable.
    def ping
      TaxCloud::Responses::Ping.parse request(:ping)
    end

    private

    # Authorization hash to use with all SOAP requests
    def auth_params
      return {} unless TaxCloud.configuration
      {
        'apiLoginID' => TaxCloud.configuration.api_login_id,
        'apiKey' => TaxCloud.configuration.api_key
      }
    end

    def client_params
      { wsdl: TaxCloud::WSDL_URL }.tap do |params|
        params[:open_timeout] = TaxCloud.configuration.open_timeout if TaxCloud.configuration.open_timeout
        params[:read_timeout] = TaxCloud.configuration.read_timeout if TaxCloud.configuration.read_timeout
      end
    end

    def safe
      yield
    rescue Savon::SOAPFault => e
      raise TaxCloud::Errors::SoapError.new(e)
    end
  end
end
