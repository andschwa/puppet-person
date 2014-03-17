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
    package { [ 'vcsh', 'mr' ]:
      ensure => installed,
    }

    vcsrepo { "${user}_dotfiles":
      ensure   => latest,
      source   => $repo,
      path     => $path,
      provider => git,
      user     => "${user}/.dotfiles",
    }

    $configdir ="${home}/.config"
    $mrconfig = "${home}/.mrconfig"

    File {
      ensure  => link,
      require => Vcsrepo["${user}_dotfiles"],
      before  => Exec["${user}_mr_update"],
    }

    file { $configdir:
      content => "${path}/.mrconfig",
    }

    file { $mrconfig:
      content => "${path}/.config",
    }

    exec { "${user}_mr_update":
      command => "mr update",
      path    => "/usr/bin",
      user    => $user,
      require => Package['mr'],
    }
  }
}
