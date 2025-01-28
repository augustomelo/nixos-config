# Nixos-config

This is heavely inspired on [nixos-config](https://github.com/mitchellh/nixos-config) for my development  machcine.

## Known issues

### UTM

- Lack of support of OpenGL 3.3 source: [OpenGL 3.3 with GPU acceleration?](https://github.com/utmapp/UTM/issues/4285).

### VMware fusion

- [Wayland not fully supported](https://github.com/vmware/open-vm-tools/issues/660)
- On MacOS problem with US international keyboard on the host and guest (double quotes not registerd), solutions:
  - Manually set the host to US
  - On VMware fusion disable  Mac Host Shortcut
  - [Input source pro](https://inputsource.pro/) 
