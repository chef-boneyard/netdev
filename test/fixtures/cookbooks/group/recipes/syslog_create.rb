
netdev_group 'syslog_group' do
        template_path 'syslog.text.erb'
        action :create
        variables({
          :syslog_names => node[:netdev][:syslog]
        })
end

