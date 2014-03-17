define person(
  $user     = $title,
  $fullname = $title,
  $groups   = $title,
  $home     = "/home/${title}",
  $packages = [],
  $password = "plaintext",
  $shell    = "bash",

  # vcsh config setup
  $use_vcsh = true,
  $repo,
  $provider = git,
  $path     = "${home}/.dotfiles"
  ) {

  ensure_packages($packages)

  group { $groups:
    ensure => present,
  }

  user { $user:
    ensure     => present,
    comment    => $fullname,
    gid        => $user,
    groups     => $groups,
    home       => $home,
    managehome => true,
    password   => sha1($password),
    shell      => $shell,
    require    => [ Group[$groups] ],
  }

  if $use_vcsh {
    package { ['vcsh', 'mr']:
      ensure => installed,
    }

    Exec {
      path => '/usr/bin',
      user => $user,
      cwd  => $home,
    }

    exec { "${user}_vcsh_clone_mr":
      command => "vcsh clone ${path}",
      creates => "${home}/.mrconfig",
      require => Package['vcsh'],
    }

    exec { "${user}_mr_update":
      command => "mr update",
      require => [ Package['mr'], Exec["${user}_vcsh_clone_mr"] ],
    }
  }
}
