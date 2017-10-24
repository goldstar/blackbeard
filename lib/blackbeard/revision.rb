module Blackbeard
  class Revision < Storable
    include Chartable

    set_master_key :revisions
    string_attributes :name

    def to_s
      id
    end

    def store_query(result, context)
      revision_data = result >= 0 ? newer_revision_data : older_revision_data
      revision_data.add(context.unique_identifier, tz.now)
    end

    def older_revision_data
      @older_data ||= AppRevisionOlderParticipantData.new(self)
    end

    def newer_revision_data
      @newer_data ||= AppRevisionNewerParticipantData.new(self)
    end

    def chartable_segments
      ['older_revisions', 'newer_revisions']
    end

    def chartable_result_for_hour(hour)
      {
        'older_revisions' => older_revision_data.participants_for_hour(hour),
        'newer_revisions' => newer_revision_data.participants_for_hour(hour)
      }
    end

    def chartable_result_for_day(date)
      {
        'older_revisions' => older_revision_data.participants_for_day(date),
        'newer_revisions' => newer_revision_data.participants_for_day(date)
      }
    end
  end
end
