{ config, pkgs, ... }:

{
  # SSD TRIM - discard unused blocks weekly
  services.fstrim.enable = true;

  # SMART monitoring daemon - alerts on drive health issues
  services.smartd.enable = true;

  # Prevent OOM system lockups
  services.earlyoom.enable = true;

  # Better IRQ distribution across CPU cores
  services.irqbalance.enable = true;

  # Automatic firmware updates (useful for laptops)
  services.fwupd.enable = true;
}
