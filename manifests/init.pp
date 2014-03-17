class person(
  $manage_vcsh     = true,
  $persons         = {},
  $person_defaults = {}) {

  if $manage_vcsh {
    package { ['vcsh', 'mr']:
      ensure => installed,
    }
  }

  # create persons
  create_resources('person::user', $persons, $person_defaults)
}
