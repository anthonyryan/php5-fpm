#Global options, install php modules(optional)
default["php_fpm"]["install_php_modules"] = false
#Global options, install php dependencies(optional)
default["php_fpm"]["install_php_dependencies"] = false
#Let the cookbook install repos for earlier versions of debian, centos and ubuntu
default["php_fpm"]["use_cookbook_repos"] = true
#Let the install recipe update and upgrade the system with hostupgrade
default["php_fpm"]["run_update"] = true

#If the cookbook is creating users, let's state who they are
default["php_fpm"]["create_users"] = false
default["php_fpm"]["users"] = 
'{ "users": 
	{ 
		"fpm_user": { "dir": "/base_path", "system": "true", "group": "fpm_group" }
	}
}'

#Install method (package or source)
default["php_fpm"]["install_method"] = "package"
#Install source version
default["php_fpm"]["source"]["version"] = "5.6"
#Install source gitbranch, can be master or version
default["php_fpm"]["source"]["branch"] = "PHP-#{node["php_fpm"]["source"]["version"]}"
#Install source file, git or tar - https://git.php.net/repository/php-src.git or https://github.com/php/php-src/tarball/master
default["php_fpm"]["source"]["url"] = "https://github.com/php/php-src/tarball/#{node["php_fpm"]["source"]["branch"]}"
#Configure source params
default["php_fpm"]["source"]["common-conf-string"] = [
  '--prefix=/usr/local/php7',
  '--enable-bcmath', 
  '--with-bz2',
  '--with-zlib',
  '--enable-zip',
  '--enable-calendar',
  '--enable-exif',
  '--enable-ftp',
  '--with-gettext',
  '--with-gd',
  '--with-jpeg-dir',
  '--with-png-dir',
  '--with-freetype-dir',
  '--with-xpm-dir',
  '--enable-mbstring',
  '--enable-mysqlnd',
  '--with-mysqli=mysqlnd',
  '--with-pdo-mysql=mysqlnd',
  '--with-openssl',
  '--enable-intl',
  '--enable-soap',
  '--with-readline',
  '--with-curl',
  '--with-mcrypt',
  '--with-xsl',
  '--with-openssl',
  '--disable-cgi'
]
default["php_fpm"]["source"]["fpm-conf-string"] = [
  '--with-config-file-path=/etc/php7/fpm',
  '--with-config-file-scan-dir=/etc/php7/fpm/conf.d',
  '--disable-cli',
  '--enable-fpm',
  '--with-fpm-user=www',
  '--with-fpm-group=www'
]
default["php_fpm"]["source"]["cli-conf-string"] = [
  '--enable-pcntl',
  '--with-config-file-path=/etc/php7/cli',
  '--with-config-file-scan-dir=/etc/php7/cli/conf.d'
]

#Select Platform Configuration
case node[:platform]
when "ubuntu", "debian"
        default["php_fpm"]["php_prefix"] = "php5"
	default["php_fpm"]["package"] = "php5-fpm"
	default["php_fpm"]["package_query"] = "dpkg-query -W"
	default["php_fpm"]["base_path"] = "/etc/#{node["php_fpm"]["php_prefix"]}/fpm"
	default["php_fpm"]["conf_file"] = node[:platform_version].include?("10.04") ? "php5-fpm.conf" : "php-fpm.conf"
	default["php_fpm"]["pools_path"] = node[:platform_version].include?("10.04") ? "#{node["php_fpm"]["base_path"]}/fpm.d" : "#{node["php_fpm"]["base_path"]}/pool.d"
	default["php_fpm"]["pools_include"] = "include=#{node["php_fpm"]["pools_path"]}/*.conf"
	default["php_fpm"]["php_modules"] = [ 'php5-common', 
						'php5-mysql', 
						'php5-curl', 
						'php5-gd'
					] #Option to add more or remove, override if needed or disable	
	default["php_fpm"]["php_dependencies"] = [ '"make",
    						"bison",
						"g++",
						"autoconf",
						"libxml2-dev",
						"libbz2-dev",
						"libcurl4-openssl-dev",
						"libltdl-dev",
						"libpng12-dev",
						"libjpeg-turbo8-dev",
						"libfreetype6-dev",
						"libxpm-dev",
						"libimlib2-dev",
						"libicu-dev",
						"libreadline6-dev",
						"libmcrypt-dev",
						"libxslt1-dev"
					] #Option to add more or remove, override if needed or disable	
when "centos", "redhat", "fedora"
        default["php_fpm"]["php_prefix"] = "php5"
	default["php_fpm"]["package"] = "php-fpm"
	default["php_fpm"]["package_query"] = "rpm -qa | grep"
	default["php_fpm"]["base_path"] = "/etc"
	default["php_fpm"]["conf_file"] = "php-fpm.conf"
	default["php_fpm"]["pools_path"] = "#{node["php_fpm"]["base_path"]}/php-fpm.d"
	default["php_fpm"]["pools_include"] = "include=#{node["php_fpm"]["pools_path"]}/*.conf"
	default["php_fpm"]["php_modules"] = [ 'php-common', 
						'php-mysql', 
						'php-curl', 
						'php-gd'
					] #Option to add more or remove, override if needed or disable
	default["php_fpm"]["php_dependencies"] = [ '"make",
    						"bison",
						"g++",
						"autoconf",
						"libxml2-dev",
						"libbz2-dev",
						"libcurl4-openssl-dev",
						"libltdl-dev",
						"libpng12-dev",
						"libjpeg-turbo8-dev",
						"libfreetype6-dev",
						"libxpm-dev",
						"libimlib2-dev",
						"libicu-dev",
						"libreadline6-dev",
						"libmcrypt-dev",
						"libxslt1-dev"
					] #Option to add more or remove, override if needed or disable	
end

#Set php-fpm.conf configuration
default["php_fpm"]["config"] = 
'{ 	"config":
	{
		"pid": "/var/run/php5-fpm.pid",
		"error_log": "/var/log/php5-fpm.log",
		"syslog.facility": "daemon",
		"syslog.ident": "php-fpm",
		"log_level": "notice",
		"emergency_restart_threshold": "0",
		"emergency_restart_interval": "0",
		"process_control_timeout": "0",
		"process.max": "0",
		"daemonize": "yes",
		"rlimit_files": "NOT_SET",
		"rlimit_core": "NOT_SET",
		"events.mechanism": "NOT_SET"
	}
}'

#Set pool configuration, default pool		
default["php_fpm"]["pools"] = 
'{ 	"www":
	{
		"user": "fpm_user",
		"group": "fpm_group",
		"listen": "127.0.0.1:9001",
		"pm": "dynamic",
		"pm.max_children": "10",
		"pm.start_servers": "4",
		"pm.min_spare_servers": "2",
		"pm.max_spare_servers": "6",
		"pm.process_idle_timeout": "10s",
		"pm.max_requests": "0",
		"pm.status_path": "/status",
		"ping.path": "/ping",
		"ping.response": "/pong",
		"access.format": "%R - %u %t \"%m %r\" %s",
		"request_slowlog_timeout": "0",
		"request_terminate_timeout": "0",
		"chdir": "/",
		"catch_workers_output": "no",
		"security.limit_extensions": ".php",
		"access.log": "NOT_SET",
		"slowlog": "NOT_SET",
		"rlimit_files": "NOT_SET",
		"rlimit_core": "NOT_SET",
		"chroot": "NOT_SET"
	}
}'

#### FOR UBUNTU 10.04 ONLY

#Set php-fpm.conf Ubuntu 10.04 configuration
default["php_fpm"]["ubuntu1004_config"] = 
'{ 	"config":
	{
		"pid": "/var/run/php5-fpm.pid",
		"error_log": "/var/log/php5-fpm.log",
		"log_level": "notice",
		"emergency_restart_threshold": "0",
		"emergency_restart_interval": "0",
		"process_control_timeout": "0",
		"daemonize": "yes",
		"rlimit_files": "NOT_SET",
		"rlimit_core": "NOT_SET",
		"events.mechanism": "NOT_SET"
	}
}'

#Set pool configuration, default pool		
default["php_fpm"]["ubuntu1004_pools"] = 
'{ 	"www":
	{
		"user": "fpm_user",
		"group": "fpm_group",
		"listen": "127.0.0.1:9001",
		"pm": "dynamic",
		"pm.max_children": "10",
		"pm.start_servers": "4",
		"pm.min_spare_servers": "2",
		"pm.max_spare_servers": "6",
		"pm.max_requests": "0",
		"pm.status_path": "/status",
		"ping.path": "/ping",
		"ping.response": "/pong",
		"request_slowlog_timeout": "0",
		"request_terminate_timeout": "0",
		"chdir": "/",
		"catch_workers_output": "no",
		"access.log": "NOT_SET",
		"slowlog": "NOT_SET",
		"rlimit_files": "NOT_SET",
		"rlimit_core": "NOT_SET",
		"chroot": "NOT_SET"
	}
}'

#### OS OVERRIDES
default["php_fpm"]["centos_pid"] = "/var/run/php-fpm/php-fpm.pid"




#### PHP7 SUPPORT
default["php_fpm"]["php7-version"] = '7.0.5'
default["php_fpm"]["php7-timezone"] = 'Europe\Bratislava'

include_attribute 'php_fpm::customize'
