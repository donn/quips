#!/usr/bin/env ruby
require 'optparse'

class Package
    attr_accessor :name
    attr_accessor :url
    attr_accessor :major
    attr_accessor :minor

    def initialize(name, url, major, minor = nil)
        @name = name
        @url = url
        @major = major
        @minor = minor
    end

    def description
        if minor == nil
            return ".Package(url: \"#{url}\", majorVersion: #{major})"
        end
        return ".Package(url: \"#{url}\", majorVersion: #{major}, minor: #{minor})"
    end
end

class String
    def bold; "\e[1m#{self}\e[22m" end
    def red;  "\e[31m#{self}\e[0m" end
    def green; "\e[32m#{self}\e[0m" end
end

::Version = ["0", "3"]
options = {}
OptionParser.new do |opts|
    opts.banner = "Usage: quips [options] [Swift files]"

    opts.on("-h", "--help", "Show this message.") do
        puts opts
        exit
    end
    opts.on("-v", "--version", "Get the version of quips you're using.") do
        puts "quips #{::Version.join('.')}"
        puts "All rights reserved."
        puts "quips is under the MIT license. Use \"quips --license\" for more information."
        exit
    end
    opts.on("-c", "--clean", "Resets the quips package cache.") do
        system("rm -rf #{Dir.home}/.quips")
        if ARGV.count < 1
            exit
        end
    end
    opts.on("--license", "Show the quips license.") do
        puts "Copyright (c) 2017 Mohamed Gaber"
        puts ""
        puts "Permission is hereby granted, free of charge, to any person obtaining a copy"
        puts "of this software and associated documentation files (the \"Software\"), to deal"
        puts "in the Software without restriction, including without limitation the rights"
        puts "to use, copy, modify, merge, publish, distribute, sublicense, and/or sell"
        puts "copies of the Software, and to permit persons to whom the Software is"
        puts "furnished to do so, subject to the following conditions:"
        puts ""
        puts "The above copyright notice and this permission notice shall be included in all"
        puts "copies or substantial portions of the Software."
        puts ""
        puts "THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR"
        puts "IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,"
        puts "FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE"
        puts "AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER"
        puts "LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,"
        puts "OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE"
        puts "SOFTWARE."
        exit
    end
end.parse!

if ARGV.count < 1
    puts "Starting Swift REPL..."
    system("swift")
end

if ARGV.count > 1
    puts "quips only supports one source file at a time."
    exit
end

if !File.file?(ARGV[0])
    puts "File #{ARGV[0]} does not exist."
    exit
end

app_name = File.basename(ARGV[0], ".swift")

quip_regex = /^\s*@quip(gh)?/
quip_locus_regex = /@quip/
quip_url_regex = /^\s*@quip\s*([^:\s]+)\s*:\s*\"(.+?)\"\s*:\s*([0-9]+)(?:\s*:\s*([0-9]+))?/
quip_gh_regex= /^\s*@quipgh\s*([^:\s]+)\s*:\s*(.+?\/.+?)\s*:\s*([0-9]+)(?:\s*:\s*([0-9]+))?/

source = []
packages = []
errors = []

File.foreach(ARGV[0]).each_with_index do |line, index|
    if line =~ quip_regex
        if line =~ quip_url_regex
            match = quip_url_regex.match(line)
            packages << Package.new(match[1], match[2], match[3], match[4])
            source << "import #{match[1]}"
        elsif line =~ quip_gh_regex
            match = quip_gh_regex.match(line)
            packages << Package.new(match[1], "https://github.com/#{match[2]}", match[3], match[4])
            source << "import #{match[1]}"
        else
            locus = line =~ quip_locus_regex
            errors << "#{ARGV[0]}:#{index}: #{"error".red}".bold + ": invalid quip".bold
            errors << line
            indent = ""
            puts locus
            for i in 0...locus
                indent += " "
            end
            indent += "^"
            errors << indent.bold.green
            source << "// failed quip //"
        end
    else
        source << line
    end
end

if errors.count > 0
    for error in errors
        STDERR.puts error
    end
end

if packages.count == 0
    system("swift #{ARGV[0]}")
    exit
end

directory = "#{Dir.home}/.quips"
subdirectory = directory + "/" + app_name

Dir.mkdir(directory) unless File.exists?(directory)
Dir.mkdir(subdirectory) unless File.exists?(subdirectory)

dependency_list = ""
packages.map{ |package| dependency_list += "#{package.description}," }

File.open("#{directory}/Package.swift", "w") {
    |file|
    file << %{
        import PackageDescription

        let package = Package(
            name: "#{app_name}",
            dependencies:
            [
                #{dependency_list}
            \]
        \)
    }
}

main = File.open("#{subdirectory}/main.swift", "w") {
    |file|
    for line in source
        file.puts line
    end
}

if errors.count == 0 
    system("if swift build -C #{directory}; then #{directory}/.build/debug/#{app_name}; fi")
    system("find #{directory} -mindepth 1 -maxdepth 1 ! -name '*.build*' | xargs rm -rf")
end