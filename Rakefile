require "bundler/gem_tasks"

$stdout.sync = true
$stderr.sync = true

gem_name = "vg-facade"
current_file = File.expand_path File.dirname(__FILE__)

namespace :acceptance do

  desc "Tests facade for each provider"

  task :build do
    sh 'gem build vg-facade'
    sh "vagrant plugin install #{gem_name}-*.gem"
  end

  task :run do
      args = []

      command = "vagrant up #{args.join(" ")}"

      Dir.foreach("#{current_file}/tests") do |f|
        next if f == '.' or f == '..'
        d = "#{current_file}/tests/#{f}"
        next if not File.directory?(d)

        Dir.chdir(d) do
          puts "Testing #{f}"
          sh command
        end
      end
  end

  task :all => [:build, :run]
end

task default: "acceptance:all"
