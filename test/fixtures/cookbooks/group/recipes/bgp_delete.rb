netdev_group 'bgp_group' do
  template_path 'bgp.xml.erb'
  action :delete
end
