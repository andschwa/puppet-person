class person::user {

  group { $person::groups:
    ensure => present,
  }

  user { $person::person:
    ensure     => present,
    comment    => $person::fullname,
    gid        => $person::person,
    groups     => $person::groups,
    home       => $person::home,
    managehome => true,
    password   => $person::password,
    shell      => '/usr/bin/zsh',
    require    => [ Group[$person::groups], Package['zsh'] ],
  }

  file { $person::directories:
    ensure  => directory,
    owner   => $person::person,
    require => User[$person::person],
  }

  $nopwsudoers = {
    'nopassword' => {
      ensure  => present,
      comment => 'Users without sudo password prompt',
      users   => $person::groups,
      runas   => [ 'root' ],
      cmnds   => [ 'ALL' ],
      tags    => [ 'NOPASSWD', 'SETENV' ],
    }
  }

  class { 'sudo':
    manage_sudoersd => true,
    sudoers         => $nopwsudoers,
  }
}
