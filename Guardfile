guard :rspec, cmd: 'bundle exec rspec' do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/blackbeard/(.+)\.rb$})     { |m| "spec/#{m[1]}_spec.rb" }
  watch(%r{^dashboard/routes/(.+)\.rb$}) { |m| "spec/dashboard/#{m[1]}_spec.rb" }
  watch(%r{^dashboard/views/(.+)/.+\.erb$}) { |m| "spec/dashboard/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb')  { "spec" }
end

