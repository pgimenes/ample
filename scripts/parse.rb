#!/usr/bin/env ruby

require 'erb'
require 'optparse'
require 'fileutils'
require 'logger'

# Custom logger
class CustomFormatter < Logger::Formatter
  def call(severity, timestamp, progname, msg)
    "[#{timestamp.strftime("%Y-%m-%d %H:%M:%S")}]::#{severity.rjust(5)}: #{msg2str(msg)}\n"
  end
end

# Initialize logger with custom formatter
logger = Logger.new(STDOUT)
logger.datetime_format = "%Y-%m-%d %H:%M:%S"
logger.formatter = CustomFormatter.new

# Parse command-line options

options = {}
default_base_path = "#{ENV['WORKAREA']}/hw/build"

OptionParser.new do |opts|
  opts.banner = "Usage: #{File.basename($PROGRAM_NAME)} [options] --files FILE1 FILE2 ..."

  opts.on("--base_path PATH", "Set the base path (default: #{default_base_path})") do |path|
    options[:base_path] = path
  end
end.parse!

# List of files to parse
files_to_parse = ARGV

# Iterate over each file
files_to_parse.each do |filename|
  logger.info("Parsing #{filename}")

  # Read the ERB file content
  erb_file = File.read(filename)
  erb = ERB.new(erb_file)
  result = erb.result(binding)

  output_filename = File.join(File.dirname(filename), File.basename(filename, '.erb'))
  output_filepath = File.join(options.fetch(:base_path, default_base_path), output_filename)

  logger.debug("Output path: #{output_filepath}")
  FileUtils.mkdir_p(File.dirname(output_filepath))
  File.write(output_filepath, result)

  logger.info("Parsed result dumped to #{output_filepath}")
end