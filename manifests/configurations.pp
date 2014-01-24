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
  }

  file { "${person::home}_freshrc": 
    ensure    => link,
    owner     => $person::person,
    group     => $person::person,
    path      => "${person::home}/.freshrc",
    target    => "${person::home}/.dotfiles/fresh/freshrc",
    require   => [ Dotfiles[$person::person],
                   Vcsrepo["${person::person}::fresh"] ],
  }

  # modeled as exec for refreshonly, removes bashrc for fresh install
  exec { "${person::home}_rm_bashrc":
    command     => "/bin/rm ${person::home}/.bashrc",
    cwd         => $person::home,
    environment => "HOME=${person::home}",
    user        => $person::person,
    refreshonly => true,
    subscribe   => File["${person::home}_freshrc"],
    before      => Exec["${person::person}::fresh_install"],
  }

  exec { "${person::person}::fresh_install":
    command     => "${person::home}/${person::fresh_path}/bin/fresh install",
    cwd         => $person::home,
    environment => "HOME=${person::home}",
    user        => $person::person,
    refreshonly => true,
    subscribe   => Exec["${person::home}_rm_bashrc"],
    before      => Exec["${person::person}::fresh_update"],
  }

  exec { "${person::person}::fresh_update":
    command     => "${person::home}/${person::fresh_path}/bin/fresh update",
    cwd         => $person::home,
    environment => "HOME=${person::home}",
    user        => $person::person,
    subscribe   => Dotfiles[$person::person],
  }
}
