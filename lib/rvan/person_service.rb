# Information on this service here:
# https://api.securevan.com/Services/V3/PersonService.asmx

module VAN
  class MatchPersonResponse < Response
    def van_id
      parsed_xml["Body"]["MatchPersonResponse"]["MatchPersonResult"]["PersonID"]
    end
    
    def van_id_type
      parsed_xml["Body"]["MatchPersonResponse"]["MatchPersonResult"]["PersonIDType"]
    end
    
    def matched?
      match_result !~ /Unmatched/
    end
    
    def match_result
      parsed_xml["Body"]["MatchPersonResponse"]["MatchPersonResult"]["MatchResultStatus"]
    end
  end
  
  class PersonService < Service
    def initialize(api_key, options = {})
      super(api_key, "/Services/V3/PersonService.asmx", options = {})
    end
    
    def apply_activist_code
    end
  
    def list_people(match_xml)
      message = create_message do |xml|
        xml.ListPeople 'xmlns' => "https://api.securevan.com/Services/V3/" do |xml|
          xml << match_xml
        end
      end
      make_request('ListPeople', message)
    end
  
    def get_person(person_id)
      message = create_message do |xml|
        xml.GetPerson 'xmlns' => "https://api.securevan.com/Services/V3/" do |xml|
          xml.PersonID(person_id)
          xml.PersonIDType("VANID")
          xml.options do
            xml.ReturnSections("Address,Phone,District,ActivistCode,EventSignups")
          end
        end
      end
      make_request('GetPerson', message)
    end
    
    # Notes about matching:
    # Matches are case insensitive, matching with last name and email address only does not work
    # Instructions can be
    #   MatchOnly: Only look for a match; don't update the database in any way.
    #   MatchAndStore: If no match is found, directly create a new person record in the database. If a match is found, update the existing record with any new information provided in the candidate.
    #   MatchAndProcess: If no match is found, add the record to the Process Volunteers queue. If a match is found, update the existing record with any new information provided in the candidate.
    #   ProcessOnly: Do not perform any matching at this time; just add the record to the Process Volunteers queue.
    def match_person(instruction, match_xml)
      message = create_message do |xml|
        xml.MatchPerson 'xmlns' => "https://api.securevan.com/Services/V3/" do |xml|
          xml << match_xml
          xml.instruction(instruction)
          xml.options
        end
      end

      MatchPersonResponse.new(make_request('MatchPerson', message).body)
    end
  
    def hello_auth_world
      message = create_message do |xml|
        xml.HelloAuthWorld 'xmlns' => "https://api.securevan.com/Services/V3/" do |xml|
          xml.msg("test")
        end
      end
      make_request('HelloAuthWorld', message)
    end
  
    def hello_world
      message = create_message do |xml|
        xml.HelloWorld 'xmlns' => "https://api.securevan.com/Services/V3/" do |xml|
          xml.msg("string")
        end
      end
      make_request('HelloWorld', message)
    end
  end
end
