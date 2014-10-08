# Here's a chef run.

There are only three important files:

    attributes/default.rb
    recipes/using_dots.rb
    recipes/using_strings.rb

Running `kitchen test --parallel --destroy=never` brings up two boxes, one
using strings for node attribute access, and one using dots for node attribute
access.

Importantly, the converge fails when using dots, catching my spelling error:

    ================================================================================
    Recipe Compile Error in /tmp/kitchen/cookbooks/test_dots/recipes/using_dots.rb
    ================================================================================

    NoMethodError
    -------------
    Undefined method or attribute `passwodr' on `node'

    Cookbook Trace:
    ---------------
      /tmp/kitchen/cookbooks/test_dots/recipes/using_dots.rb:3:in `block in from_file'
      /tmp/kitchen/cookbooks/test_dots/recipes/using_dots.rb:1:in `from_file'

    Relevant File Content:
    ----------------------
    /tmp/kitchen/cookbooks/test_dots/recipes/using_dots.rb:

      1:  template '/etc/admin_config' do
      2:    source 'admin_config.erb'
      3>>   variables(:password => node.passwodr)
      4:  end
      5:

Whereas when using strings my spelling error is *not* caught: the run converges
with no warnings, and ends up with an empty password:

    $ kitchen login using_strings
    vagrant@using-strings-ubuntu-1204:~$ cat /etc/admin_config
    user = admin
    password =

There are obviously lots of places where this would be undesirable, take a long
time to debug, and even possibly introduce a security vulnerability.

And here's the full run of test-kitchen:

    bwm@muon /tmp/test_dots [master]
     % kitchen test --parallel --destroy=never
    -----> Starting Kitchen (v1.2.1)
    -----> Cleaning up any prior instances of <using-strings-ubuntu-1204>
    -----> Cleaning up any prior instances of <using-dots-ubuntu-1204>
    -----> Destroying <using-strings-ubuntu-1204>...
    -----> Destroying <using-dots-ubuntu-1204>...
           ==> default: Forcing shutdown of VM...
           ==> default: Destroying VM and associated drives...
           Vagrant instance <using-strings-ubuntu-1204> destroyed.
           Finished destroying <using-strings-ubuntu-1204> (0m3.93s).
    -----> Testing <using-strings-ubuntu-1204>
    -----> Creating <using-strings-ubuntu-1204>...
           ==> default: Forcing shutdown of VM...
           ==> default: Destroying VM and associated drives...
           Vagrant instance <using-dots-ubuntu-1204> destroyed.
           Finished destroying <using-dots-ubuntu-1204> (0m7.91s).
    -----> Testing <using-dots-ubuntu-1204>
    -----> Creating <using-dots-ubuntu-1204>...
           Bringing machine 'default' up with 'virtualbox' provider...
           ==> default: Importing base box 'opscode-ubuntu-12.04'...
           ==> default: Matching MAC address for NAT networking...
           ==> default: Setting the name of the VM: using-strings-ubuntu-1204_default_1412796159949_17527
           Skipping Berkshelf with --no-provision
           ==> default: Fixed port collision for 22 => 2222. Now on port 2200.
           ==> default: Clearing any previously set network interfaces...
           ==> default: Preparing network interfaces based on configuration...
               default: Adapter 1: nat
           ==> default: Forwarding ports...
               default: 22 => 2200 (adapter 1)
           ==> default: Booting VM...
           ==> default: Waiting for machine to boot. This may take a few minutes...
               default: SSH address: 127.0.0.1:2200
               default: SSH username: vagrant
               default: SSH auth method: private key
               default: Warning: Connection timeout. Retrying...
           ==> default: Machine booted and ready!
           ==> default: Checking for guest additions in VM...
           ==> default: Setting hostname...
           ==> default: Machine not provisioning because `--no-provision` is specified.
           Vagrant instance <using-strings-ubuntu-1204> created.
           Finished creating <using-strings-ubuntu-1204> (0m40.65s).
    -----> Converging <using-strings-ubuntu-1204>...
           Preparing files for transfer
           Resolving cookbook dependencies with Berkshelf 3.1.5...
           Removing non-cookbook files before transfer
    -----> Installing Chef Omnibus (true)
    downloading https://www.getchef.com/chef/install.sh
      to file /tmp/install.sh
    trying wget...
    Downloading Chef  for ubuntu...
    downloading https://www.getchef.com/chef/metadata?v=&prerelease=false&nightlies=false&p=ubuntu&pv=12.04&m=x86_64
      to file /tmp/install.sh.1195/metadata.txt
    trying wget...
    url     https://opscode-omnibus-packages.s3.amazonaws.com/ubuntu/12.04/x86_64/chef_11.16.2-1_amd64.deb
    md5     a2b20f34bc7d7dc0a6e0636caa314c03
    sha256  dd3360ea2fd238f3bec962bdb3bb179060701bc67ac5cad3eed4be1b1c1afe8f
    downloaded metadata file looks valid...
    downloading https://opscode-omnibus-packages.s3.amazonaws.com/ubuntu/12.04/x86_64/chef_11.16.2-1_amd64.deb
      to file /tmp/install.sh.1195/chef_11.16.2-1_amd64.deb
    trying wget...
           Bringing machine 'default' up with 'virtualbox' provider...
           ==> default: Importing base box 'opscode-ubuntu-12.04'...
    Progress: 10%Comparing checksum with sha256sum...
    Installing Chef
    installing with dpkg...
    Selecting previously unselected package chef.
    (Reading database ... 56035 files and directories currently installed.)
    Unpacking chef (from .../chef_11.16.2-1_amd64.deb) ...
           ==> default: Matching MAC address for NAT networking...
           ==> default: Setting the name of the VM: using-dots-ubuntu-1204_default_1412796197652_42027
           Skipping Berkshelf with --no-provision
    Setting up chef (11.16.2-1) ...
    Thank you for installing Chef!
           Transfering files to <using-strings-ubuntu-1204>
    [2014-10-08T19:23:19+00:00] INFO: Forking chef instance to converge...
    [2014-10-08T19:23:19+00:00] WARN:
    * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
    SSL validation of HTTPS requests is disabled. HTTPS connections are still
    encrypted, but chef is not able to detect forged replies or man in the middle
    attacks.

    To fix this issue add an entry like this to your configuration file:

    ```
      # Verify all HTTPS connections (recommended)
      ssl_verify_mode :verify_peer

      # OR, Verify only connections to chef-server
      verify_api_cert true
    ```

    To check your SSL configuration, or troubleshoot errors, you can use the
    `knife ssl check` command like so:

           ```
             knife ssl check -c /tmp/kitchen/solo.rb
           ```

           * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

    Starting Chef Client, version 11.16.2
    [2014-10-08T19:23:19+00:00] INFO: *** Chef 11.16.2 ***
    [2014-10-08T19:23:19+00:00] INFO: Chef-client pid: 1278
           ==> default: Fixed port collision for 22 => 2222. Now on port 2201.
           ==> default: Clearing any previously set network interfaces...
           ==> default: Preparing network interfaces based on configuration...
               default: Adapter 1: nat
           ==> default: Forwarding ports...
               default: 22 => 2201 (adapter 1)
    [2014-10-08T19:23:21+00:00] INFO: Setting the run_list to ["recipe[test_dots::using_strings]"] from CLI options
    [2014-10-08T19:23:21+00:00] INFO: Run List is [recipe[test_dots::using_strings]]
    [2014-10-08T19:23:21+00:00] INFO: Run List expands to [test_dots::using_strings]
    [2014-10-08T19:23:21+00:00] INFO: Starting Chef Run for using-strings-ubuntu-1204
    [2014-10-08T19:23:21+00:00] INFO: Running start handlers
    [2014-10-08T19:23:21+00:00] INFO: Start handlers complete.
    Compiling Cookbooks...
    Converging 1 resources
    Recipe: test_dots::using_strings
      * template[/etc/admin_config] action create[2014-10-08T19:23:21+00:00] INFO: Processing template[/etc/admin_config] action create (test_dots::using_strings line 1)
    [2014-10-08T19:23:21+00:00] INFO: template[/etc/admin_config] created file /etc/admin_config

        - create new file /etc/admin_config[2014-10-08T19:23:21+00:00] INFO: template[/etc/admin_config] updated file contents /etc/admin_config

        - update content in file /etc/admin_config from none to d04d6a
        --- /etc/admin_config       2014-10-08 19:23:21.709338223 +0000
        +++ /tmp/chef-rendered-template20141008-1278-tr3tdm 2014-10-08 19:23:21.709338223 +0000
        @@ -1 +1,3 @@
        +user = admin
        +password = [2014-10-08T19:23:21+00:00] INFO: template[/etc/admin_config] mode changed to 644

        - change mode from '' to '0644'
    [2014-10-08T19:23:21+00:00] INFO: Chef Run complete in 0.022856033 seconds

    Running handlers:
    [2014-10-08T19:23:21+00:00] INFO: Running report handlers
    Running handlers complete
    [2014-10-08T19:23:21+00:00] INFO: Report handlers complete
    Chef Client finished, 1/1 resources updated in 2.67144581 seconds
           Finished converging <using-strings-ubuntu-1204> (0m16.67s).
    -----> Setting up <using-strings-ubuntu-1204>...
           ==> default: Booting VM...
           ==> default: Waiting for machine to boot. This may take a few minutes...
               default: SSH address: 127.0.0.1:2201
               default: SSH username: vagrant
               default: SSH auth method: private key
    Fetching: thor-0.19.0.gem (100%)
    Fetching: busser-0.6.2.gem (100%)
    Successfully installed thor-0.19.0
    Successfully installed busser-0.6.2
    2 gems installed
    -----> Setting up Busser
           Creating BUSSER_ROOT in /tmp/busser
           Creating busser binstub
               default: Warning: Connection timeout. Retrying...
           ==> default: Machine booted and ready!
           ==> default: Checking for guest additions in VM...
           ==> default: Setting hostname...
           ==> default: Machine not provisioning because `--no-provision` is specified.
           Vagrant instance <using-dots-ubuntu-1204> created.
           Finished creating <using-dots-ubuntu-1204> (1m14.49s).
    -----> Converging <using-dots-ubuntu-1204>...
           Preparing files for transfer
           Resolving cookbook dependencies with Berkshelf 3.1.5...
           Removing non-cookbook files before transfer
           Plugin bats installed (version 0.2.0)
    -----> Running postinstall for bats plugin
    Installed Bats to /tmp/busser/vendor/bats/bin/bats
    -----> Installing Chef Omnibus (true)
           downloading https://www.getchef.com/chef/install.sh
             to file /tmp/install.sh
           trying wget...
           Finished setting up <using-strings-ubuntu-1204> (0m21.25s).
    -----> Verifying <using-strings-ubuntu-1204>...
           Suite path directory /tmp/busser/suites does not exist, skipping.
    Uploading /tmp/busser/suites/bats/default.bats (mode=0644)
    Downloading Chef  for ubuntu...
    downloading https://www.getchef.com/chef/metadata?v=&prerelease=false&nightlies=false&p=ubuntu&pv=12.04&m=x86_64
      to file /tmp/install.sh.1170/metadata.txt
    trying wget...
    -----> Running bats test suite
     ✗ config file does not exist
       (in test file /tmp/busser/suites/bats/default.bats, line 2)

    1 test, 1 failure
    Command [/tmp/busser/vendor/bats/bin/bats /tmp/busser/suites/bats] exit code was 1
    url     https://opscode-omnibus-packages.s3.amazonaws.com/ubuntu/12.04/x86_64/chef_11.16.2-1_amd64.deb
    md5     a2b20f34bc7d7dc0a6e0636caa314c03
    sha256  dd3360ea2fd238f3bec962bdb3bb179060701bc67ac5cad3eed4be1b1c1afe8f
    downloaded metadata file looks valid...
    downloading https://opscode-omnibus-packages.s3.amazonaws.com/ubuntu/12.04/x86_64/chef_11.16.2-1_amd64.deb
      to file /tmp/install.sh.1170/chef_11.16.2-1_amd64.deb
    trying wget...
    Comparing checksum with sha256sum...
    Installing Chef
    installing with dpkg...
    Selecting previously unselected package chef.
    (Reading database ... 56035 files and directories currently installed.)
    Unpacking chef (from .../chef_11.16.2-1_amd64.deb) ...
    Setting up chef (11.16.2-1) ...
    Thank you for installing Chef!
           Transfering files to <using-dots-ubuntu-1204>
    [2014-10-08T19:23:55+00:00] INFO: Forking chef instance to converge...
    [2014-10-08T19:23:55+00:00] WARN:
    * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
    SSL validation of HTTPS requests is disabled. HTTPS connections are still
    encrypted, but chef is not able to detect forged replies or man in the middle
    attacks.

    To fix this issue add an entry like this to your configuration file:

    ```
      # Verify all HTTPS connections (recommended)
      ssl_verify_mode :verify_peer

      # OR, Verify only connections to chef-server
      verify_api_cert true
    ```

    To check your SSL configuration, or troubleshoot errors, you can use the
    `knife ssl check` command like so:

           ```
             knife ssl check -c /tmp/kitchen/solo.rb
           ```

           * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

    Starting Chef Client, version 11.16.2
    [2014-10-08T19:23:55+00:00] INFO: *** Chef 11.16.2 ***
    [2014-10-08T19:23:55+00:00] INFO: Chef-client pid: 1253
    [2014-10-08T19:23:57+00:00] INFO: Setting the run_list to ["recipe[test_dots::using_dots]"] from CLI options
    [2014-10-08T19:23:57+00:00] INFO: Run List is [recipe[test_dots::using_dots]]
    [2014-10-08T19:23:57+00:00] INFO: Run List expands to [test_dots::using_dots]
    [2014-10-08T19:23:57+00:00] INFO: Starting Chef Run for using-dots-ubuntu-1204
    [2014-10-08T19:23:57+00:00] INFO: Running start handlers
    [2014-10-08T19:23:57+00:00] INFO: Start handlers complete.
    Compiling Cookbooks...

    ================================================================================
    Recipe Compile Error in /tmp/kitchen/cookbooks/test_dots/recipes/using_dots.rb
    ================================================================================

    NoMethodError
    -------------
    Undefined method or attribute `passwodr' on `node'

    Cookbook Trace:
    ---------------
      /tmp/kitchen/cookbooks/test_dots/recipes/using_dots.rb:3:in `block in from_file'
      /tmp/kitchen/cookbooks/test_dots/recipes/using_dots.rb:1:in `from_file'

    Relevant File Content:
    ----------------------
    /tmp/kitchen/cookbooks/test_dots/recipes/using_dots.rb:

      1:  template '/etc/admin_config' do
      2:    source 'admin_config.erb'
      3>>   variables(:password => node.passwodr)
      4:  end
      5:


    Running handlers:
    [2014-10-08T19:23:57+00:00] ERROR: Running exception handlers
    Running handlers complete
    [2014-10-08T19:23:57+00:00] ERROR: Exception handlers complete
    [2014-10-08T19:23:57+00:00] FATAL: Stacktrace dumped to /tmp/kitchen/cache/chef-stacktrace.out
    Chef Client failed. 0 resources updated in 2.270118478 seconds
    [2014-10-08T19:23:57+00:00] ERROR: Undefined method or attribute `passwodr' on `node'
    [2014-10-08T19:23:58+00:00] FATAL: Chef::Exceptions::ChildConvergeError: Chef run process exited unsuccessfully (exit code 1)
    >>>>>> Converge failed on instance <using-dots-ubuntu-1204>.
    >>>>>> Please see .kitchen/logs/using-dots-ubuntu-1204.log for more details
    >>>>>> ------Exception-------
    >>>>>> Class: Kitchen::ActionFailed
    >>>>>> Message: SSH exited (1) for command: [sudo -E chef-solo --config /tmp/kitchen/solo.rb --json-attributes /tmp/kitchen/dna.json  --log_level info]
    >>>>>> ----------------------
