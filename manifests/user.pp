define person::user(
  $user        = $title,
  $fullname    = $title,
  $groups      = $title,
  $home        = "/home/${title}",
  $manage_home = true,
  $packages    = [],
  $password    = 'plaintext',
  $shell       = '/usr/bin/bash',
  $make_groups   = [],

  # vcsh config setup
  $repo        = undef
  ) {

  include person

  ensure_packages($packages)

  group { $make_groups:
    ensure => present,
  }

  user { $user:
    ensure     => present,
    comment    => $fullname,
    gid        => $user,
    groups     => $groups,
    home       => $home,
    managehome => $manage_home,
    password   => $password,
    shell      => $shell,
    require    => [ Group[$groups] ],
  }

  if $person::manage_vcsh and $repo != undef {

    Exec {
      path        => ['/bin', '/usr/bin'],
      user        => $user,
      cwd         => $home,
      environment => ["HOME=${home}"],
    }

    exec { "${user}_vcsh_clone_mr":
      command => "vcsh clone ${repo} mr",
      creates => "${home}/.mrconfig",
      require => Package['vcsh'],
    }

    exec { "${user}_mr_update":
      command => 'mr update',
      require => [ Package['mr'], Exec["${user}_vcsh_clone_mr"] ],
    }
  }
}
