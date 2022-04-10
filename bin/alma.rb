#!/usr/bin/env ruby

$LOAD_PATH << './lib'
$LOAD_PATH << './lib/alma'
$LOAD_PATH << './lib/alma/providers'

require './lib/alma'

Alma::Orgeo::Provider.new(countries: {}, regions: {}).find_events
