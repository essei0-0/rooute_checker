require "rooute_checker/version"
require 'optparse'

module RoouteChecker
  class << self
    attr_accessor :config
    def configure
      self.config ||= Config.new
      yield(config)
    end

    def setup
      load "#{Dir.pwd}/examples/config/initializers/rooute_checker.rb"
    end
  end

  class Config
    attr_accessor :stack_root_dir
    attr_accessor :load_dir
    attr_accessor :scan_config_dir
    # スタックについて、どこの呼び出し元まで遡るか
    # scan時にどこのディレクトリ配下のファイル(class)を読み込んでおくか。
    # scan時に実行するメソッドの情報ををどこのディレクトリ配下から読み取るか。
    def initialize
      @stack_root_dir = Dir.pwd
      @load_dir = Dir.pwd
      @scan_config_dir = Dir.pwd + "/config"
    end
  end

  class Command
    def initialize
      @options = {}
      parse_options
    end
    def parse_options
      OptionParser.new do |opts|
        opts.banner = "Usage: rooute_checker [command] [options]"
      end.parse!
    end
  end

  # exec method and scan
  require 'yaml'
  class ScanCommand < Command
    def parse_options
      OptionParser.new do |opts|
        opts.banner = "Usage: rooute_checker scan [options] [file_names] or rooute_checker s [options] [file_names]"
        opts.on("-a", "--all") do |v|
          @options[:all] = v
        end
      end.parse!
    end

    def run(*args)
      # load class files
      load_rb("#{RoouteChecker.config.load_dir}/**/*.rb")

      if @options[:all]
        Dir.glob("#{RoouteChecker.config.scan_config_dir}/**/*.yml").each do |file|
          data = YAML.load_file(file)
          scan(data)
        end
      else
        # load scan settings
        args.each do |file|
          data = YAML.load_file("#{RoouteChecker.config.scan_config_dir}/#{file}")
          scan(data)
        end
      end
    end
    def load_rb(path)
      Dir.glob(path).each do |file|
        load file
      end
    end
    def scan(data)
      class_names = data.keys
      class_names.each do |class_name|
        methods = data[class_name]["methods"]
        methods.each do |method|
          method_name = method["name"]
          method_args = method["args"]

          Object.const_get(class_name).new.send(method_name, *method_args)
        end
      end
    end
  end

  # analyze data and create summary
  class AnalyzeCommand < Command
    def parse_options
      OptionParser.new do |opts|
        opts.banner = "Usage: rooute_checker analyze [options] or rooute_checker a [options]"
        opts.on("-o VAL", "--output") do |v|
          @options[:force] = v
        end
      end.parse!
    end

    def run
      # todo implement
      puts "not implemented"
    end
  end

  # output summary
  class ReportCommand < Command
    def parse_options
      OptionParser.new do |opts|
        opts.banner = "Usage: rooute_checker report [options] or rooute_checker r [options]"
        opts.on("-o VAL", "--output") do |v|
          @options[:force] = v
        end
      end.parse!
    end

    def run
      # todo implement
      puts "not implemented"
    end
  end

  # output summary
  class NoCommand < Command
    def error(command_name)
      puts "Unknown command: #{command_name}"
    end
  end

  def self.get_class_from_lineno(file_path, lineno)
    # ファイルを開いてクラス名を取得する
    current_lineno = 0
    class_name = nil
    File.open(file_path, 'r') do |file|
      file.each_line do |line|
        current_lineno += 1
        # ファイルを上から順に読み込んでいくため、行数が過ぎたら中断する
        break if current_lineno > lineno
        if line.match(/class\s+([\w:]+)\b/)
          class_name = $1
        end
      end
    end
  
    class_name
  end
end

def pointer
  space_size = 40
  puts "#{' '* space_size}"
  puts "#{'#'* space_size}"
  puts "#{' '* space_size}"
  stack = caller_locations.select{ |s| s.absolute_path.start_with?(RoouteChecker.config.stack_root_dir) }
  r_stack = stack.reverse
  r_stack.map! do |s|
    class_name = RoouteChecker::get_class_from_lineno(s.absolute_path, s.lineno)
    "#{class_name}##{s.label}"
  end
  root_label = r_stack.first
  caller_label = r_stack.last
  puts "method #{caller_label}'s root is '#{root_label}'"
  puts "route from pointer to root is as follows:"

  route = r_stack.join(" -> ")
  puts route
  puts "#{' '* space_size}"
  puts "#{'#'* space_size}"
end