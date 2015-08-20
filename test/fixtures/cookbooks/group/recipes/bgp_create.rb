
netdev_group 'bgp_group' do
        template_path 'bgp.xml.erb'
        action :create
        variables({
          :bgp => node[:netdev][:bgp]
        })
end

