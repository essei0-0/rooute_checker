#!/usr/bin/env ruby
require "bundler/setup"
require "rooute_checker"

RoouteChecker::setup

command_name = ARGV[0]
case command_name
# exec methods and scan
when "scan"
  command = RoouteChecker::ScanCommand.new
  command.run(*ARGV[1..-1])
when "analyze"
  command = RoouteChecker::AnalyzeCommand.new
  command.run
when "report"
  command = RoouteChecker::ReportCommand.new
  command.run
else
  command = RoouteChecker::NoCommand.new
  command.error(command_name)
end