class person(
  $person,
  $fullname,
  $home,
  $password,
  $groups,
  $directories,
  $dotfiles_repo,
  $fresh_repo,
  $fresh_path,
  $emacs_d_repo,
) {

  include person::user
  include person::configurations
}
