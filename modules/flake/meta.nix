# Facts about the owner and this repo that other modules reference.
# `flake.meta` is not a standard output; it exists purely for internal reuse.
{
  flake.meta = {
    owner = {
      username = "brandon";
      name = "Brandon Talbot";
      email = "bjtal91@gmail.com";
    };

    # Where this repo is checked out on every host.
    flakePath = "/home/brandon/.config/NixOS";
  };
}
