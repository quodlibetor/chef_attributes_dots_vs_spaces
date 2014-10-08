template '/etc/admin_config' do
  source 'admin_config.erb'
  variables(:password => node.passwodr)
end
