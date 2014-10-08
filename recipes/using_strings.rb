template '/etc/admin_config' do
  source 'admin_config.erb'
  mode '0644'
  variables(:password => node['passwodr'])
end
