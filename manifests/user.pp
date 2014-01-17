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
}
