# customized settings

normal["php_fpm"]["install_php_modules"] = true
normal["php_fpm"]["install_php_dependencies"] = true
normal["php_fpm"]["use_cookbook_repos"] = false
normal["php_fpm"]["run_update"] = false
normal["php_fpm"]["create_users"] = false
normal["php_fpm"]["php_prefix"] = "php7"
#normal["php_fpm"]["install_method"] = "source"
normal["php_fpm"]["source"]["version"] = "7.0.5"

normal["php_fpm"]["pools"] =
'{      "www":
        {
                "user": "www",
                "group": "www",
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

normal["php_fpm"]["ubuntu1004_pools"] =
'{      "www":
        {
                "user": "www",
                "group": "www",
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

#normal['php_fpm']['emergency_restart_threshold'] = '10'
#normal['php_fpm']['emergency_restart_interval'] = '1m'
#normal['php_fpm']['process_control_timeout'] = '10s'
