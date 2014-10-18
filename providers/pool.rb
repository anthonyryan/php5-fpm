#action create
action :create do

    #if the file exists and we are not overwritting, alert
    if @current_resource.exists && !@current_resource.overwrite
        Chef::Log.info "#{ @new_resource } already exists - please set to overwrite if you wish to replace this file"
    elsif @current_resource.exists && @current_resource.overwrite
        #otherwise converge the file by creating it
        converge_by("Replace #{ @new_resource }") do
            delete_file
            create_file
        end

    else
        #otherwise converge the file by creating it
        converge_by("Create #{ @new_resource }") do
            create_file
        end
    
    end

end

#action modify
action :modify do

    #must make sure the file exists
    if @current_resource.exists
        #if so, converge by modifying the file
        converge_by("Modifying #{ @new_resource }") do
            modify_file
        end

    else
        #otherwise alert
        Chef::Log.info "#{ @new_resource } does not exist. Please create first with action :create"
    end

end

#action delete
action :delete do

    #must make sure the file exists
    if @current_resource.exists
        #if so, converge by modifying the file
        converge_by("Deleting #{ @new_resource }") do
            delete_file
        end

    else
        #otherwise alert
        Chef::Log.info "#{ @new_resource } does not exist. Please create first with action :create"
    end

end

#must load current resource state
def load_current_resource
    @current_resource = Chef::Resource::Php5FpmPool.new(@new_resource.name)
    #default entries, will override if file exists and can find a matching configuration key
    #Overwrite
    @current_resource.overwrite(@new_resource.overwrite)
    #Base Pool Configuration
    @current_resource.pool_name(@new_resource.pool_name)
    @current_resource.pool_user(@new_resource.pool_user)
    @current_resource.pool_group(@new_resource.pool_group)
    @current_resource.listen_address(@new_resource.listen_address)
    @current_resource.listen_port(@new_resource.listen_port)
    @current_resource.listen_allowed_clients(@new_resource.listen_allowed_clients) # <<<<<<<<<< Need to complete
    @current_resource.listen_owner(@new_resource.listen_owner)
    @current_resource.listen_group(@new_resource.listen_group)
    @current_resource.listen_mode(@new_resource.listen_mode)
    #PM Configuration
    @current_resource.pm(@new_resource.pm)
    @current_resource.pm_max_children(@new_resource.pm_max_children)
    @current_resource.pm_start_servers(@new_resource.pm_start_servers)
    @current_resource.pm_min_spare_servers(@new_resource.pm_min_spare_servers)
    @current_resource.pm_max_spare_servers(@new_resource.pm_max_spare_servers)
    @current_resource.pm_process_idle_timeout(@new_resource.pm_process_idle_timeout)
    @current_resource.pm_max_requests(@new_resource.pm_max_requests)
    @current_resource.pm_status_path(@new_resource.pm_status_path)
    #Ping Status
    @current_resource.ping_path(@new_resource.ping_path)
    @current_resource.ping_response(@new_resource.ping_response)
    #Logging
    @current_resource.access_format(@new_resource.access_format)
    @current_resource.request_slowlog_timeout(@new_resource.request_slowlog_timeout)
    @current_resource.request_terminate_timeout(@new_resource.request_terminate_timeout)
    @current_resource.access_log(@new_resource.access_log)
    @current_resource.slow_log(@new_resource.slow_log)
    #Misc
    @current_resource.chdir(@new_resource.chdir)
    @current_resource.chroot(@new_resource.chroot)
    @current_resource.catch_workers_output(@new_resource.catch_workers_output)
    @current_resource.security_limit_extensions(@new_resource.security_limit_extensions)
    @current_resource.rlimit_files(@new_resource.rlimit_files)
    @current_resource.rlimit_core(@new_resource.rlimit_core)

    #if the file exists, load current state
    if file_exists?(@current_resource.pool_name)

        #open the file for read
        ::File.open("#{ node[:php_fpm][:pools_path] }/#{ @current_resource.pool_name }.conf", "r") do |fobj|

            #loop through each line
            fobj.each_line do |fline|

                #Split the line for configuration value
                lstring = fline.split('=').at(1)

                #Start base configuration
                configuration_exists(fline,"user =") ? @current_resource.pool_user(lstring.chomp.strip) : nil
                if configuration_exists(fline,"group =") && !configuration_exists(fline,"listen.group =")
                    @current_resource.pool_group(lstring.chomp.strip)
                end

                #Pull address and port
                if configuration_exists(fline,"listen =")
                    #split away the address and port
                    sp_address = lstring.split(':').at(0)
                    sp_port = lstring.split(':').at(1)
                    #remove newline chars and whitespacing
                    @current_resource.listen_address(sp_address.chomp.strip)
                    @current_resource.listen_port(sp_port.chomp.strip.to_i)
                end

                #Finish out base configuration options
                configuration_exists(fline,"listen.allowed_clients =") ? @current_resource.listen_allowed_clients(lstring.chomp.strip) : nil
                configuration_exists(fline,"listen.owner =") ? @current_resource.listen_owner(lstring.chomp.strip) : nil
                configuration_exists(fline,"listen.group =") ? @current_resource.listen_group(lstring.chomp.strip) : nil
                configuration_exists(fline,"listen.mode =") ? @current_resource.listen_mode(lstring.chomp.strip) : nil

                #Start PM configuration
                configuration_exists(fline,"pm =") ? @current_resource.pm(lstring.chomp.strip) : nil
                configuration_exists(fline,"pm.max_children =") ? @current_resource.pm_max_children(lstring.chomp.strip.to_i) : nil
                configuration_exists(fline,"pm.start_servers =") ? @current_resource.pm_start_servers(lstring.chomp.strip.to_i) : nil
                configuration_exists(fline,"pm.min_spare_servers =") ? @current_resource.pm_min_spare_servers(lstring.chomp.strip.to_i) : nil
                configuration_exists(fline,"pm.max_spare_servers =") ? @current_resource.pm_max_spare_servers(lstring.chomp.strip.to_i) : nil
                configuration_exists(fline,"pm.process_idle_timeout =") ? @current_resource.pm_process_idle_timeout(lstring.chomp.strip) : nil
                configuration_exists(fline,"pm.max_requests =") ? @current_resource.pm_max_requests(lstring.chomp.strip.to_i) : nil
                configuration_exists(fline,"pm.status_path =") ? @current_resource.pm_status_path(lstring.chomp.strip) : nil

                #Start ping status
                configuration_exists(fline,"ping.path =") ? @current_resource.ping_path(lstring.chomp.strip) : nil
                configuration_exists(fline,"ping.response =") ? @current_resource.ping_response(lstring.chomp.strip) : nil

                #Start logging
                configuration_exists(fline,"access.format =") ? @current_resource.access_format(lstring.chomp.strip) : nil
                configuration_exists(fline,"request_slowlog_timeout =") ? @current_resource.request_slowlog_timeout(lstring.chomp.strip.to_i) : nil
                configuration_exists(fline,"request_terminate_timeout =") ? @current_resource.request_terminate_timeout(lstring.chomp.strip.to_i) : nil
                configuration_exists(fline,"access.log =") ? @current_resource.access_log(lstring.chomp.strip) : nil
                configuration_exists(fline,"slowlog =") ? @current_resource.slow_log(lstring.chomp.strip) : nil

                #Start misc
                configuration_exists(fline,"chdir =") ? @current_resource.chdir(lstring.chomp.strip) : nil
                configuration_exists(fline,"chroot =") ? @current_resource.chroot(lstring.chomp.strip) : nil
                configuration_exists(fline,"catch_workers_output =") ? @current_resource.catch_workers_output(lstring.chomp.strip) : nil
                configuration_exists(fline,"security.limit_extensions =") ? @current_resource.security_limit_extensions(lstring.chomp.strip) : nil
                configuration_exists(fline,"rlimit_files =") ? @current_resource.rlimit_files(lstring.chomp.strip) : nil
                configuration_exists(fline,"rlimit_core =") ? @current_resource.rlimit_core(lstring.chomp.strip) : nil

            end

        end

        #flag that they current file exists
        @current_resource.exists = true
    end

end

#method for creating a pool file
def create_file

    #open the file and put new values in
    Chef::Log.debug "Creating file #{ node[:php_fpm][:pools_path] }/#{ @new_resource.pool_name }.conf!"
    ::File.open("#{ node[:php_fpm][:pools_path] }/#{ @new_resource.pool_name }.conf", "w") do |f|

        f.puts "[#{ @new_resource.pool_name }]"

        f.puts "###### Base Pool Configuration"
        f.puts "user = #{ @new_resource.pool_user }"
        f.puts "group = #{ @new_resource.pool_group }"
        f.puts "listen = #{ @new_resource.listen_address }:#{ @new_resource.listen_port }"

        @current_resource.listen_allowed_clients != nil ? (f.puts "listen.allowed_clients = #{ @new_resource.listen_allowed_clients }") : nil
        @current_resource.listen_owner != nil ? (f.puts "listen.owner = #{ @new_resource.listen_owner }") : nil
        @current_resource.listen_group != nil ? (f.puts "listen.group = #{ @new_resource.listen_group }") : nil
        @current_resource.listen_mode != nil ? (f.puts "listen.mode = #{ @new_resource.listen_mode }") : nil

        f.puts "###### PM Configuration"
        @current_resource.pm != nil ? (f.puts "pm = #{ @new_resource.pm }") : nil
        @current_resource.pm_max_children != nil ? (f.puts "pm.max_children = #{ @new_resource.pm_max_children }") : nil
        @current_resource.pm_start_servers != nil ? (f.puts "pm.start_servers = #{ @new_resource.pm_start_servers }") : nil
        @current_resource.pm_min_spare_servers != nil ? (f.puts "pm.min_spare_servers = #{ @new_resource.pm_min_spare_servers }") : nil
        @current_resource.pm_max_spare_servers != nil ? (f.puts "pm.max_spare_servers = #{ @new_resource.pm_max_spare_servers }") : nil
        @current_resource.pm_process_idle_timeout != nil ? (f.puts "pm.process_idle_timeout = #{ @new_resource.pm_process_idle_timeout }") : nil
        @current_resource.pm_max_requests != nil ? (f.puts "pm.max_requests = #{ @new_resource.pm_max_requests }") : nil
        @current_resource.pm_status_path != nil ? (f.puts "pm.status_path = #{ @new_resource.pm_status_path }") : nil

        f.puts "###### Ping Status"
        @current_resource.ping_path != nil ? (f.puts "ping.path = #{ @new_resource.ping_path }") : nil
        @current_resource.ping_response != nil ? (f.puts "ping.response = #{ @new_resource.ping_response }") : nil

        f.puts "###### Logging"
        @current_resource.access_format != nil ? (f.puts "access.format = #{ @new_resource.access_format }".gsub! '\\', '') : nil
        @current_resource.request_slowlog_timeout != nil ? (f.puts "request_slowlog_timeout = #{ @new_resource.request_slowlog_timeout }") : nil
        @current_resource.request_terminate_timeout != nil ? (f.puts "request_terminate_timeout = #{ @new_resource.request_terminate_timeout }") : nil
        @current_resource.access_log != nil ? (f.puts "access.log = #{ @new_resource.access_log }") : nil
        @current_resource.slow_log != nil ? (f.puts "slowlog = #{ @new_resource.slow_log }") : nil

        f.puts "###### Misc"
        @current_resource.chdir != nil ? (f.puts "chdir = #{ @new_resource.chdir }") : nil
        @current_resource.chroot != nil ? (f.puts "chroot = #{ @new_resource.chroot }") : nil
        @current_resource.catch_workers_output != nil ? (f.puts "catch_workers_output = #{ @new_resource.catch_workers_output }") : nil
        @current_resource.security_limit_extensions != nil ? (f.puts "security.limit_extensions = #{ @new_resource.security_limit_extensions }") : nil
        @current_resource.rlimit_files != nil ? (f.puts "rlimit_files = #{ @new_resource.rlimit_files }") : nil
        @current_resource.rlimit_core != nil ? (f.puts "rlimit_core = #{ @new_resource.rlimit_core }") : nil

    end

end

#method for removing a pool file
def delete_file

    #delete the file
    Chef::Log.debug "Removing file #{ node[:php_fpm][:pools_path] }/#{ @new_resource.pool_name }.conf!"
    ::File.delete("#{ node[:php_fpm][:pools_path] }/#{ @new_resource.pool_name }.conf")

end

#method for modifying a pool file
def modify_file

    file_name = "#{ node[:php_fpm][:pools_path] }/#{ @current_resource.pool_name }.conf"

    #Start Base Configuration
    find_replace(file_name,"user = ",@current_resource.pool_user,@new_resource.pool_user)
    find_replace(file_name,"group = ",@current_resource.pool_group,@new_resource.pool_group)

    #Replace IP Address and Port
    if @current_resource.listen_address != @new_resource.listen_address || @current_resource.listen_port != @new_resource.listen_port
        find_replace(file_name,"listen = ","#{ @current_resource.listen_address }:#{ @current_resource.listen_port }","#{ @new_resource.listen_address }:#{ @new_resource.listen_port }")
    end

    find_replace(file_name,"listen.allowed_clients = ",@current_resource.listen_allowed_clients,@new_resource.listen_allowed_clients)
    find_replace(file_name,"listen.owner = ",@current_resource.listen_owner,@new_resource.listen_owner)
    find_replace(file_name,"listen.group = ",@current_resource.listen_group,@new_resource.listen_group)
    find_replace(file_name,"listen.mode = ",@current_resource.listen_mode,@new_resource.listen_mode)

    #Start PM configuration
    find_replace(file_name,"pm = ",@current_resource.pm,@new_resource.pm)
    find_replace(file_name,"pm.max_children = ",@current_resource.pm_max_children,@new_resource.pm_max_children)
    find_replace(file_name,"pm.start_servers = ",@current_resource.pm_start_servers,@new_resource.pm_start_servers)
    find_replace(file_name,"pm.min_spare_servers = ",@current_resource.pm_min_spare_servers,@new_resource.pm_min_spare_servers)
    find_replace(file_name,"pm.max_spare_servers = ",@current_resource.pm_max_spare_servers,@new_resource.pm_max_spare_servers)
    find_replace(file_name,"pm.process_idle_timeout = ",@current_resource.pm_process_idle_timeout,@new_resource.pm_process_idle_timeout)
    find_replace(file_name,"pm.max_requests = ",@current_resource.pm_max_requests,@new_resource.pm_max_requests)
    find_replace(file_name,"pm.status_path = ",@current_resource.pm_status_path,@new_resource.pm_status_path)

    #Start Logging
    find_replace(file_name,"access.format = ",@current_resource.access_format,@new_resource.access_format.gsub("\\",""))
    find_replace(file_name,"request_slowlog_timeout = ",@current_resource.request_slowlog_timeout,@new_resource.request_slowlog_timeout)
    find_replace(file_name,"request_terminate_timeout = ",@current_resource.request_terminate_timeout,@new_resource.request_terminate_timeout)
    find_replace(file_name,"access.log = ",@current_resource.access_log,@new_resource.access_log)
    find_replace(file_name,"slowlog = ",@current_resource.slow_log,@new_resource.slow_log)

    #Start Misc
    find_replace(file_name,"chdir = ",@current_resource.chdir,@new_resource.chdir)
    find_replace(file_name,"chroot = ",@current_resource.chroot,@new_resource.chroot)
    find_replace(file_name,"catch_workers_output = ",@current_resource.catch_workers_output,@new_resource.catch_workers_output)
    find_replace(file_name,"security.limit_extensions = ",@current_resource.security_limit_extensions,@new_resource.security_limit_extensions)
    find_replace(file_name,"rlimit_files = ",@current_resource.rlimit_files,@new_resource.rlimit_files)
    find_replace(file_name,"rlimit_core = ",@current_resource.rlimit_core,@new_resource.rlimit_core)

end

#method for finding configuration values in existing configurations
def configuration_exists(conf_line,find_str)

    #Check that the configuration attribute exists
    conf_line.include?(find_str)

end

#method for finding and replacing the configuration values
def find_replace(file_name,attribute,find_str,replace_str)

    if find_str != replace_str
        #if the string is found, replace
        Chef::Log.debug "Line in #{ file_name } - #{ find_str } does not match desired configuration, updating with #{ replace_str }"
        ::File.write(f = "#{ file_name }", ::File.read(f).gsub("#{ attribute }#{ find_str }","#{ attribute }#{ replace_str }"))
    end

end

#method for checking if the pool file exists
def file_exists?(name)

    #if file exists return true
    Chef::Log.debug "Checking to see if the curent file: '#{ name }.conf' exists in pool directory #{ node[:php_fpm][:pools_path] }"
    ::File.file?("#{ node[:php_fpm][:pools_path] }/#{ name }.conf")

end


