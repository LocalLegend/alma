module Alma
  module Orgeo
    class Provider < Alma::Provider
      include HTTParty
      base_uri 'orgeo.ru'

      URLS = {
        events: '/event/index/type/athletics',
        event: '/event',
        participants: '/event/participants',
        registration: '/event/registration',
      }

      REGIONS = {
        '25' => 'primorsky',
      }

      def url_generator(type:, region: nil, id: nil)
        if ['event', 'participants', 'registration'].include?(type) && id.nil?
          raise ArgumentError, "Expected id argument for type #{type}"
        end

        case type
        when 'events'
          region.nil? ? URLS[:events] : "#{URLS[:events]}/region/#{region}/no_national/1"
        when 'event'
          "#{URLS[:event]}/#{id}"
        when 'participants'
          "#{URLS[:participants]}/#{id}"
        when 'registration'
          "#{URLS[:registration]}/#{id}"
        end
      end

      def initialize(countries:, regions:)
        super(countries: countries, regions: regions)
      end

      def find_events
        next_url = url_generator(type: 'events', region: nil)
        result = []

        while !next_url.nil?
          htlm_data = self.class.get(next_url, {})
          document = Nokogiri::HTML(htlm_data.body)
          events = document.css('.event_view_block')
          next_url = next_page(document)

          page_result = events.map do |t|
            OrgeoEvent.create!(t)
          end
          result += page_result.compact
        end

        pp result
      end

      def available_regions
        REGIONS
      end

      private
      
      def next_page(document)
        pagination = document.css('.pagination')
        return nil if pagination.empty?
        return nil unless pagination.css('li.next.disabled').empty?
        pagination.css('.next').css('a').first['href']
      end
    end

    class OrgeoEvent < Models::Event
      def self.create!(html_data)
        event = self.new
        event.parse_event_item(html_data)
      end

      def upgrade_event!(html_data)
        document = Nokogiri::HTML(html_data.body)
        document = document.css('#content')
        # {
        #   title:  document.css('h1').text.strip,
        self.images =
          document.css('img').map { |link| "#{link['src']}" },
          #   # place: place,
          #   date: document.css('.visible-xs-inline').text.strip,
          #   distances: document.css('.hint').text.strip,
          #   organizators: document.css('.event_top_info_right td').map do |org|
          #     next if org.text.strip.empty?
          #     "#{org.text.strip} #{org.css('a').map { |l| l['href'] }.first}"
          #   end.compact,
          #   links: document.css('a').map do |link|
          #     {
          #       title: link.text.strip,
          #       url: link['href'],
          #     }
          #   end,
          # }
          self.organizators = document.css('.event_top_info_right td').map do |org|
            next if org.text.strip.empty?
            org.text.strip
          end.compact
        self
      end

      def parse_event_item(html_data)
        self.images =
          html_data.css('img').map { |link| "#{link['src']}" }
        self.place =
          html_data.css('.event-place').text.strip
        date_string = html_data.css('.visible-xs-inline').text.strip
        self.date = parse_date(date_string)
        self.description = html_data.css('.hint').text.strip
        self.links = html_data.css('a').map do |link|
          {
            title: link.text.strip,
            url: link['href'],
          }
        end

        self.title = parse_title(links[0][:title])
        self.id = parse_id(links)
        self
      end

      private

      def parse_title(title)
        title[(title.rindex('- ') + 1)..-1].strip.capitalize
      end

      def parse_id(links)
        links[0][:url].match(/\A\/event\/(.*)\z/)[1]
      end

      def parse_date(date_string)
        Date.parse date_string
      end
    end
  end
end
