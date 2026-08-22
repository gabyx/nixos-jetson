{ ... }:
{
  boot = {
    # Bootloader ================================================================
    loader.grub = {
      # no need to set devices,
      # disko will add all devices that have a EF02 partition to the list already
      devices = [ "/dev/sda" ];
      efiSupport = true;
      efiInstallAsRemovable = true;
    };
    # ===========================================================================

    ### Temp Files ==============================================================
    tmp.useTmpfs = false;
    tmp.cleanOnBoot = true;
    # ===========================================================================
  };
}
