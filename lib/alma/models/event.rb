module Alma
  module Models
    class Event
      attr_accessor :id,
        :title,
        :description,
        :place,
        :date,
        :links,
        :images,
        :organizators

      def self.create!(_html_data)
        raise NotImplementedError, "#create! is not supported by #{self.class.name}."
      end

      def parse_event_item(_html_data)
        raise NotImplementedError, "#parse_event_item is not supported by #{self.class.name}."
      end

      def output_event_item
        raise NotImplementedError, "#output_event_item is not supported by #{self.class.name}."
      end
    end
  end
end
