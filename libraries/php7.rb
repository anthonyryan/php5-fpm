# Helper to identify if php7 is already installed
module Php7Helper
  include Chef::Mixin::ShellOut

  def php7_installed?
    cmd = shell_out("php -v | grep -q #{node['php_fpm']['php7-version']}")
    if (cmd.exitstatus == 0)
      return true
    else
      return false
    end
  end
end

Chef::Resource.send(:include, Php7Helper)
