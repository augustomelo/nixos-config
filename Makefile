.PHONY: check-env copy partition-format-install install-user-config sync-config

HOSTNAME ?= unset
NIXADDR ?= unset
NIXPORT ?= 22
NIXUSER ?= augusto

MAKEFILE_DIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

# SSH options that are used. These aren't meant to be overridden but are
# reused a lot so we just store them up here.
SSH_OPTIONS=-o PubkeyAuthentication=no -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no

backup:
	rsync -av $(HOSTNAME):/etc/nixos/ $(MAKEFILE_DIR)/transfer/

check-env:
	@echo "Check if the enviroment variables are installed";
	@if [ "$(HOSTNAME)" == "unset" ]; then \
		echo "HOSTNAME is not set. Availble options are: devbox or home-server"; \
		exit 1; \
	fi

copy:
	rsync -av -e 'ssh $(SSH_OPTIONS) -p$(NIXPORT)' \
		$(MAKEFILE_DIR)/transfer/ root@$(NIXADDR):/etc/nixos

# Is mandatory to set the password to be able to ssh
# sudu su
# passwd
partition-format-install:
	ssh $(SSH_OPTIONS) -p$(NIXPORT) root@$(NIXADDR) " \
		parted /dev/nvme0n1 --script -- \
			mklabel gpt \
			mkpart root ext4 512MB -8GB \
			mkpart swap linux-swap -8GB 100% \
			mkpart ESP fat32 1MB 512MB \
			set 3 esp on && \
		mkfs.ext4 -L nixos /dev/nvme0n1p1 && \
		mkswap -L swap /dev/nvme0n1p2 && \
		swapon /dev/nvme0n1p2 && \
		mkfs.fat -F 32 -n boot /dev/nvme0n1p3; \
		mount /dev/disk/by-label/nixos /mnt && \
		mkdir -p /mnt/boot && \
		mount -o umask=077 /dev/disk/by-label/boot /mnt/boot && \
		nixos-generate-config --root /mnt && \
		sed --in-place '/system\.stateVersion = .*/a \
			nix.settings.experimental-features = [ \"nix-command\" \"flakes\" ];\n \
			services.openssh.enable = true;\n \
			services.openssh.settings.PasswordAuthentication = true;\n \
			services.openssh.settings.PermitRootLogin = \"yes\";\n \
			users.users.root.initialPassword = \"root\";\n \
		' /mnt/etc/nixos/configuration.nix && \
		nixos-install --no-root-passwd && \
		umount /mnt/boot && \
		swapoff -a && \
		reboot; \
	"
 
install-user-config: check-env
	# Since git doesn't allow clone anonymously using ssh, we need to perform a set afterwards
	ssh $(SSH_OPTIONS) -p$(NIXPORT) root@$(NIXADDR) " \
		cd / && \
		nix shell nixpkgs#git --command git clone https://github.com/augustomelo/nixos-config.git && \
		cd /nixos-config && \
		nixos-rebuild switch --flake \".#${HOSTNAME}\" && \
		nix shell nixpkgs#git --command git remote set-url origin git@github.com:augustomelo/nixos-config.git && \
		mv /nixos-config /home/${NIXUSER}/workspace/personal/ && \
		chown -R ${NIXUSER}: /home/${NIXUSER}/workspace/personal/nixos-config && \
		reboot; \
	"
sync-config:
	rsync -av --exclude='transfer/' --exclude='.envrc' \
		$(MAKEFILE_DIR)/ $(NIXUSER)@$(HOSTNAME):/home/$(NIXUSER)/workspace/personal/nixos-config
