class person::configurations {

  require person::user

  dotfiles { $person::person: 
    source => $person::dotfiles_repo,
  }

  vcsrepo { "${person::person}::emacs":
    ensure   => present,
    provider => git,
    source   => $person::emacs_d_repo,
    path     => "${person::home}/.emacs.d",
    revision => 'master',
    user     => $person::person,
  }
  
  vcsrepo { "${person::person}::fresh":
    ensure   => latest,
    provider => git,
    source   => $person::fresh_repo,
    path     => "${person::home}/${person::fresh_path}",
    revision => 'master',
    user     => $person::person,
  } -> file { 'freshrc': 
    ensure    => link,
    owner     => $person::person,
    group     => $person::person,
    path      => "${person::home}/.freshrc",
    target    => "${person::home}/.dotfiles/fresh/freshrc",
    require   => Dotfiles[$person::person]
  } -> file { "${person::person}::bashrc":
    ensure => absent,
    path   => "${person::home}/.bashrc",
  } -> exec { "${person::person}::fresh_install":
    command     => "${person::home}/${person::fresh_path}/bin/fresh install",
    cwd         => $person::home,
    environment => "HOME=${person::home}",
    user        => $person::person,
  }

  exec { "${person::person}::fresh_update":
    command     => "${person::home}/${person::fresh_path}/bin/fresh update",
    cwd         => $person::home,
    environment => "HOME=${person::home}",
    user        => $person::person,
    subscribe   => Dotfiles[$person::person],
    require     => Exec["${person::person}::fresh_install"],
  }
}
