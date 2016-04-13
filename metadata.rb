name             'netdev'
maintainer       'Chef Software, Inc.'
maintainer_email 'releng@chef.io'
license          'Apache 2.0'
description      'Provides a set of vendor-neutral resources for managing networking devices'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '2.1.0'

source_url 'https://github.com/chef-partners/netdev' if respond_to?(:source_url)
issues_url 'https://github.com/chef-partners/netdev/issues' if respond_to?(:issues_url)
