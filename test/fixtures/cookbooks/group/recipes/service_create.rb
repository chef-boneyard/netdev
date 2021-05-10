netdev_group 'service_group' do
  template_path 'services.set.erb'
  action :create
  variables(services: node['netdev']['services'])
end
