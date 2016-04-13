netdev_group 'syslog_group' do
  template_path 'syslog.text.erb'
  action :delete
end
