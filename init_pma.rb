require 'rubygems'
require "http"
require 'oj'
require 'timeout'
require 'erb'

begin
  metadata = Timeout::timeout(5) do
    Oj.load HTTP.auth("Bearer #{ENV['METADATA_AUTH']}").get("#{ENV['METADATA_URL']}").body
  end

  unless metadata
    puts "Timeout reached during metadata lookup, exiting."
    exit 1
  end

  pma_conf = <<-EOF
<?php
$cfg['blowfish_secret'] = '<%= SecureRandom.urlsafe_base64(32) %>';
$cfg['ShowChgPassword'] = false;
$cfg['ZeroConf'] = false;
$i = 0;
<% metadata['services'].each do |service| -%>
<% next if service.dig('image','role').nil? -%>
<% next unless service['image']['role'] == 'mysql' -%>
<% service['containers'].each do |server| -%>
$i++;
$cfg['Servers'][$i]['auth_type'] = 'cookie';
$cfg['Servers'][$i]['host'] = '<%= server['ip'] %>';
$cfg['Servers'][$i]['port'] = "3306";
$cfg['Servers'][$i]['connect_type'] = 'tcp';
$cfg['Servers'][$i]['compress'] = false;
$cfg['Servers'][$i]['AllowNoPassword'] = false;
<% end -%>
<% end -%>
?>  
EOF

  pma_conf_file = ERB.new pma_conf, nil, '-'

  File.open('/var/www/html/default/config.inc.php', 'w') do |f|
    f.write pma_conf_file.result(binding)
  end

  `chmod 644 /var/www/html/default/config.inc.php`

rescue => e
  puts "Fatal error: #{e.message}"
  exit 1
end