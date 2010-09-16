require "yard"

spec = Gem::Specification.load(Dir["*.gemspec"].first)

desc "Build the Gem"
task :build do
  sh "gem build #{spec.name}.gemspec"
end

desc "Install #{spec.name} locally"
task :install=>:build do
  sudo = "sudo" unless File.writable?( Gem::ConfigMap[:bindir])
  sh "#{sudo} gem install #{spec.name}-#{spec.version}.gem"
end

desc "Push new release to gemcutter and git tag"
task :push=>["build"] do
  sh "git push"
  puts "Tagging version #{spec.version} .."
  sh "git tag v#{spec.version}"
  sh "git push --tag"
  puts "Building and pushing gem .."
  sh "gem push #{spec.name}-#{spec.version}.gem"
end

YARD::Rake::YardocTask.new do |doc|
  doc.files = FileList["lib/**/*.rb"]
end

task :clobber do
  rm_rf %w{doc .yardoc}
end
