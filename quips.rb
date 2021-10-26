#!/usr/bin/env ruby
require 'optparse'

class Package
    attr_accessor :name
    attr_accessor :url
    attr_accessor :semver

    def initialize(name, url, semver)
        @name = name
        @url = url
        @semver = semver
    end

    def description
        return ".package(url: \"#{url}\", from: \"#{semver}\")"
    end
end

class String
    def bold; "\e[1m#{self}\e[22m" end
    def red;  "\e[31m#{self}\e[0m" end
    def green; "\e[32m#{self}\e[0m" end
end

::Version = ["0", "5"]
options = {}
OptionParser.new do |opts|
    opts.banner = "Usage: quips [options] [Swift files]"

    opts.on("-h", "--help", "Show this message.") do
        puts opts
        exit
    end
    opts.on("-v", "--version", "Get the version of quips you're using.") do
        puts "quips #{::Version.join('.')}"
        puts "quips is available under the Unlicense. Use \"quips --license\" for more information."
        exit
    end
    opts.on("-c", "--clean", "Resets the quips package cache.") do
        system("rm -rf #{Dir.home}/.quips")
        if ARGV.count < 1
            exit
        end
    end
    opts.on("--license", "Show the quips license.") do
        puts <<-HEREDOC
This is free and unencumbered software released into the public domain.

Anyone is free to copy, modify, publish, use, compile, sell, or
distribute this software, either in source code form or as a compiled
binary, for any purpose, commercial or non-commercial, and by any
means.

In jurisdictions that recognize copyright laws, the author or authors
of this software dedicate any and all copyright interest in the
software to the public domain. We make this dedication for the benefit
of the public at large and to the detriment of our heirs and
successors. We intend this dedication to be an overt act of
relinquishment in perpetuity of all present and future rights to this
software under copyright law.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.

For more information, please refer to <http://unlicense.org/>
        HEREDOC
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
quip_url_regex = /^\s*@quip\s*([^:\s]+)\s*:\s*\"(.+?)\"\s*:\s*((0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)(?:-((?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\.(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?(?:\+([0-9a-zA-Z-]+(?:\.[0-9a-zA-Z-]+)*))?)/
quip_gh_regex= /^\s*@quipgh\s*([^:\s]+)\s*:\s*(.+?\/.+?)\s*:\s*((0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)(?:-((?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\.(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?(?:\+([0-9a-zA-Z-]+(?:\.[0-9a-zA-Z-]+)*))?)/

source = []
packages = []
errors = []

File.foreach(ARGV[0]).each_with_index do |line, index|
    if line =~ quip_regex
        if line =~ quip_url_regex
            match = quip_url_regex.match(line)
            packages << Package.new(match[1], match[2], match[3])
            source << "import #{match[1]}"
        elsif line =~ quip_gh_regex
            match = quip_gh_regex.match(line)
            packages << Package.new(match[1], "https://github.com/#{match[2]}", match[3])
            source << "import #{match[1]}"
        else
            locus = line =~ quip_locus_regex
            errors << "#{ARGV[0]}:#{index}: #{"error".red}".bold + ": invalid quip".bold
            errors << line
            indent = ""
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
dependency_array = "#{packages.map {|package| package.name}}"

File.open("#{directory}/Package.swift", "w") {
    |file|
    file << %{
        // swift-tools-version:5.5.0
        import PackageDescription

        let package = Package(
            name: "#{app_name}",
            dependencies: [
                #{dependency_list}
            ],
            targets: [
                .executableTarget(
                    name: "#{app_name}",
                    dependencies: #{dependency_array},
                    path: "#{app_name}"
                ),
            ]
        )
    }
}

main = File.open("#{subdirectory}/main.swift", "w") {
    |file|
    for line in source
        file.puts line
    end
}


system("if swift build --package-path #{directory} && [ 0 -eq #{errors.count} ]; then #{directory}/.build/debug/#{app_name}; fi")
system("find #{directory} -mindepth 1 -maxdepth 1 ! -name '*.build*' | xargs rm -rf")