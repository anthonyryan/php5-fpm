#
# Cookbook Name:: php-fpm
# Recipe:: configure_fpm
#
# Copyright 2014, Stajkowski
#
# All rights reserved - Do Not Redistribute
#
#     _       _       _       _       _       _       _    
#   _( )__  _( )__  _( )__  _( )__  _( )__  _( )__  _( )__ 
# _|     _||     _||     _||     _||     _||     _||     _|
#(_ P _ ((_ H _ ((_ P _ ((_ - _ ((_ F _ ((_ P _ ((_ M _ (_ 
#  |_( )__||_( )__||_( )__||_( )__||_( )__||_( )__||_( )__|


#Select Platform
case node[:platform]
when "ubuntu", "debian"

	#Create Pool Configuration
	template "#{node[:php_fpm][:ubuntu_debian][:base_path]}/php-fpm.conf" do
		source "php-fpm.erb"
		action :create
		notifies :restart, "service[#{node[:packages][:ubuntu_debian][:fpm]}]", :delayed
	end

end