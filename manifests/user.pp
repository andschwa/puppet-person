define person::user(
  $user        = $title,
  $fullname    = $title,
  $groups      = $title,
  $home        = "/home/${title}",
  $manage_home = true,
  $packages    = [],
  $password    = "plaintext",
  $shell       = "/usr/bin/bash",

  # vcsh config setup
  $repo,
  $provider    = git) {

  include person

  ensure_packages($packages)

  group { $groups:
    ensure => present,
  }

  user { $user:
    ensure     => present,
    comment    => "${fullname}",
    gid        => $user,
    groups     => $groups,
    home       => $home,
    managehome => $manage_home,
    password   => sha1($password),
    shell      => $shell,
    require    => [ Group[$groups] ],
  }

  if $person::manage_vcsh {

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
      command => "mr update",
      require => [ Package['mr'], Exec["${user}_vcsh_clone_mr"] ],
    }
  }
}
