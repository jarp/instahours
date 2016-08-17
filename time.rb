#!/usr/bin/env ruby
require_relative 'runners/time_runner'

runner = TimeRunner.new
runner.confirm
runner.set_date
runner.list_time
runner.list_commits
runner.go_to_web
