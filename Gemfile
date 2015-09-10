source 'https://rubygems.org'

gem 'junos-ez-stdlib', git: 'https://github.com/Juniper/ruby-junos-ez-stdlib.git',
                       tag: 'v0.2.0_20130819_1'

group :lint do
  gem 'foodcritic', '~> 4.0'
  gem 'rubocop', '~> 0.33'
  gem 'rake'
end

group :unit do
  gem 'berkshelf',  '~> 3.2'
  gem 'chefspec',   '~> 4.3'
end

group :kitchen_common do
  gem 'test-kitchen', '~> 1.4'
end

group :kitchen_vagrant do
  gem 'kitchen-vagrant', '~> 0.18'
end

group :kitchen_cloud do
  gem 'kitchen-digitalocean'
  gem 'kitchen-ec2'
end
