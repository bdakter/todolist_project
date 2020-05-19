require 'rake/testtask'

desc 'Say hello'
task :hello do
  puts "Hello this is the 'hello' task."
end

desc 'Run tests'
task default: [:test]

Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.libs << 'lib'
  t.test_files = FileList['test/**/t_*.rb']
end

desc 'start pry'
task :pry do
  load
end