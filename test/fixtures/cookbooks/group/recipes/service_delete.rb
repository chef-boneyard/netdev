netdev_group 'service_group' do
  template_path 'services.set.erb'
  action :delete
end
