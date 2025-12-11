# Nixos-config

This is heavely inspired on [nixos-config](https://github.com/mitchellh/nixos-config) for my development  machine.

## Home-server hardware

[GMKtec NucBox G3 Plus Intel® Twin Lake N150](https://de.gmktec.com/en/products/gmktec-nucbox-g3-plus-intel%C2%AE-twin-lake-n150)

| Item         | Description |
| ------------ | ----------- |
| CPU          | [Intel® Twin Lake N-150](https://www.intel.com/content/www/us/en/products/sku/241636/intel-processor-n150-6m-cache-up-to-3-60-ghz/specifications.html) | 
| GPU          | Intel® UHD Grafik (UP 1000 MHz) |
| Memory       | 32GB (max supported) - DDR4 3200 MT/s, SO-DIMM*1 |
| Storage      | M.2 2280 PCIe expandable up to 2TB; M.2 2242 SATA expandable up to 2TB - PCI being used |
| Connectivity | WiFi 6, Realtek 8852BE 802.11a/b/g/n/ac/ax, transmission speed 1201Mbps, supports up to 12 devices. BT 5.2 |

## Known issues

### UTM

- Lack of support of OpenGL 3.3 source: [OpenGL 3.3 with GPU acceleration?](https://github.com/utmapp/UTM/issues/4285).

### VMware fusion

- [Wayland not fully supported](https://github.com/vmware/open-vm-tools/issues/660)
- On MacOS problem with US international keyboard on the host and guest (double quotes not registerd), solutions:
  - Manually set the host to US
  - On VMware fusion disable  Mac Host Shortcut
  - [Input source pro](https://inputsource.pro/) 
