define person::user(
  $user          = $title,
  $fullname      = $title,
  $groups        = $title,
  $make_groups   = [],
  $home          = "/home/${title}",
  $manage_home   = true,
  $packages      = [],
  $password      = 'system-hash',
  $shell         = '/bin/bash',

  # user cron jobs
  $cron_jobs     = {},
  $cron_defaults = {
    user        => $title,
    target      => $title,
    environment => 'PATH=/home/andrew/bin:/usr/local/bin:/usr/bin:/bin' },

  # vcsh config setup
  $repo          = false
  ) {

  include person

  ensure_packages($packages)

  create_resources(cron, $cron_jobs, $cron_defaults)

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
  }

  if $repo {

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
