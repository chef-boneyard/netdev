source 'https://rubygems.org'

gem 'junos-ez-stdlib', git: 'https://github.com/Juniper/ruby-junos-ez-stdlib.git',
                       tag: '1.0.0'

group :lint do
  gem 'foodcritic', '~> 5.0'
  gem 'rake'
  gem 'rubocop', '~> 0.49.0'
end

group :unit do
  gem 'berkshelf',  '~> 4.0'
  gem 'chefspec',   '~> 4.4'
end

group :kitchen_common do
  gem 'test-kitchen', '~> 1.4'
end

group :kitchen_vagrant do
  gem 'kitchen-vagrant', '~> 0.19'
end

group :kitchen_cloud do
  gem 'kitchen-digitalocean'
  gem 'kitchen-ec2'
end
