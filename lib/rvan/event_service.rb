# Information on this service here:
# https://api.securevan.com/Services/V3/EventService.asmx

module VAN
  class ListEventsResponse < Response
    # Returns an array of events
    def events
      parsed_xml["Body"]["ListEventsResponse"]["ListEventsResult"]["Events"]["Event"]
    end
  end

  class EventResponse < Response
    def event
      parsed_xml["Body"]["Event"]
    end
  end

  class EventService < Service

    STATUSES = {
      :completed => 2,
      :confirmed => 7,
      :declined => 4,
      :invited => 6,
      :left_message => 5,
      :no_show => 3,
      :scheduled => 1
    }

    def initialize(api_key, options = {})
      super(api_key, "/Services/V3/EventService.asmx", options = {})
    end

    def get_event(event_id)
      message = create_message do |xml|
        xml.GetEvent 'xmlns' => "https://api.securevan.com/Services/V3/" do |xml|
          xml.EventID(event_id)
          xml.options do
            xml.ReturnSections("NextOccurrences")
          end
        end
      end
      make_request('GetEvent', message)
    end

    def list_events(after_date = Time.now)
      message = create_message do |xml|
        xml.ListEvents 'xmlns' => "https://api.securevan.com/Services/V3/" do |xml|
          xml.criteria do
            xml.Status("Active Inactive Archived")
            xml.StartingAfter(after_date.strftime("%Y-%m-%d"))
          end
        end
      end
      ListEventsResponse.new(make_request('ListEvents', message).body)
    end

    def list_event_types
    end
  end
end