require 'patron'
require 'xmlsimple'

module VAN
  class Service
    BASE_URL = "https://api.securevan.com"

    def initialize(api_key, service_path, options = {})
      @api_key = api_key
      @service_path = service_path
    end

    def make_request(action_name, body)
      headers = {
        "Accept" => nil,
        "Content-Type" => "text/xml; charset=utf-8",
        "SOAPAction" => "\"https://api.securevan.com/Services/V3/#{action_name}\""
      }
      http_client = Patron::Session.new
      http_client.base_url = BASE_URL
      http_client.insecure = true # SSL cert is invalid, have to ignore it
      response = http_client.post(@service_path, body, headers)
    end

    def create_message
      envelope_namespaces = {
        'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
        'xmlns:xsd' => 'http://www.w3.org/2001/XMLSchema',
        'xmlns:soap' => 'http://schemas.xmlsoap.org/soap/envelope/'
      }
      xml = Builder::XmlMarkup.new
      xml.instruct! :xml, :version=>"1.0", :encoding=>"UTF-8"
      message = xml.soap :Envelope, envelope_namespaces do |xml|
        xml.soap :Header do |xml|
          xml.Header 'xmlns' => 'https://api.securevan.com/Services/V3/' do |xml|
            xml.APIKey(@api_key)
            xml.DatabaseMode('MyCampaign')
          end
        end
        xml.soap :Body do |xml|
          yield xml
        end
      end
      message
    end
  end

  class Response
    attr_reader :raw_xml
    attr_reader :parsed_xml

    def initialize(xml)
      @raw_xml = xml
      @parsed_xml = XmlSimple.xml_in(xml, {'ForceArray' => false})
      @parsed_xml = @parsed_xml["Envelope"] if @parsed_xml["Envelope"]
    end

    def success?
      parsed_xml["Body"] && parsed_xml["Body"]["Fault"].nil?
    end

    def error_string
      parsed_xml["Body"]["Fault"]["faultstring"]
    end

    def error_detail
      parsed_xml["Body"]["Fault"]["detail"]
    end

    def error_code
      parsed_xml["Body"]["Fault"]["faultcode"]
    end

    def lookup_error_message
      code = error_code.match(/(\d+)/)[1] rescue nil
      ERROR[code] || "Could not find error message"
    end
  end

  ERRORS = {
    # 000 - Fatal Errors
    '000' => 'Fatal Error',
    '001' => 'Unknown',
    '002' => 'ServiceUnavailable',
    '003' => 'Method',
    '004' => 'RequestLimit',
    '005' => 'UnauthorizedIP',
    '006' => 'HTTPSRequred',
    '007' => 'BadSession',
    '008' => 'LoginFailed',

    # 100 - Invalid Requests
    '100' => 'InvalidParam',
    '101' => 'InvalidAPIKey',
    '102' => 'InvalidDBMode',
    '103' => 'InvalidReturnOption',

    # 200 - Permissions
    '200' => 'PermissionsVANID',
    '205' => 'PermissionsSavedList',

    # 300 - Invalid parameters
    '300' => 'InvalidVANID',
    '301' => 'InvalidPersonIDType',
    '302' => 'InvalidActivistCodeID',
    '303' => 'InvalidSurveyQuestionID',
    '304' => 'InvalidSurveyQuestionResponseID',
    '305' => 'InvalidSavedListID',
    '306' => 'InvalidCommitteeID',
    '307' => 'InvalidFolderID',
    '308' => 'InvalidScriptID',
    '309' => 'InvalidUserID',
    '310' => 'InvalidVolunteerActivityID',
    '311' => 'InvalidVolunteerEventID',

    # 400 - No records
    '400' => 'NotFound',
    '404' => 'NoResultsReturned',

    # 500 - Utility problems
    '500' => 'AddressParse',
  }
end