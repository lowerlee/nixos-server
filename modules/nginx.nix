[k@nixos-server:/etc/nixos]$ build
building the system configuration...
evaluation warning: system.stateVersion is not set, defaulting to 25.05. Read why this matters on https://nixos.org/manual/nixos/stable/options.html#opt-system.stateVersion.
error:
       … while calling the 'head' builtin
         at /nix/store/6zgbbqlr7nnfxpzkyj7fsl4fpg89jbw0-source/lib/attrsets.nix:1574:11:
         1573|         || pred here (elemAt values 1) (head values) then
         1574|           head values
             |           ^
         1575|         else

       … while evaluating the attribute 'value'
         at /nix/store/6zgbbqlr7nnfxpzkyj7fsl4fpg89jbw0-source/lib/modules.nix:846:9:
          845|     in warnDeprecation opt //
          846|       { value = addErrorContext "while evaluating the option `${showOption loc}':" value;
             |         ^
          847|         inherit (res.defsFinal') highestPrio;

       … while evaluating the option `system.build.toplevel':

       … while evaluating definitions from `/nix/store/6zgbbqlr7nnfxpzkyj7fsl4fpg89jbw0-source/nixos/modules/system/activation/top-level.nix':

       (stack trace truncated; use '--show-trace' to show the full, detailed trace)

       error:
       Failed assertions:
       - The ‘fileSystems’ option does not specify your root file system.
       - You must set the option ‘boot.loader.grub.devices’ or 'boot.loader.grub.mirroredBoots' to make the system bootable.