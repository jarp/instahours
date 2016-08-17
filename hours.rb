#!/usr/bin/env ruby
require_relative 'hours_runner'
runner = HoursRunner.new

runner.confirm
runner.set_date

begin
  begin
    runner.show_entries
  end while runner.add_hours == 'y'
rescue
  runner.show_entries
end

runner.complete
runner.go_to_web
