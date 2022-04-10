module Alma
  class Provider
    attr_accessor :countries, :regions

    def initialize(countries:, regions: [])
      self.countries = countries
      self.regions = regions
    end

    # start collect events from provider
    def find_events
      raise NotImplementedError, "#find_events is not supported by #{self.class.name}."
    end

    # return accessible countries and regions
    def available_regions
      raise NotImplementedError, "#available_regions is not supported by #{self.class.name}."
    end

    def available_countries
      raise NotImplementedError, "#available_countries is not supported by #{self.class.name}."
    end
  end
end
