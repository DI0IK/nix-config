{ config, pkgs, ... }:

let
  winSandbox = pkgs.writeShellScriptBin "win-sandbox" ''
        set -euo pipefail

        VM_BASE_DIR="/persist/vms/windows-sandbox"
        DEFAULT_VM_CONF="$VM_BASE_DIR/windows-11.conf"

        export TMPDIR="$VM_BASE_DIR/tmp"
        mkdir -p "$TMPDIR"

        show_help() {
          cat <<'EOF'
    win-sandbox - Lightweight Disposable Windows Sandbox for NixOS

    Commands:
      run             Start the Windows sandbox in disposable mode.
                      Any changes made during the session (files, extensions, etc.)
                      are stored in temporary RAM/overlay and completely discarded on exit.

      edit            Start the Windows sandbox in maintenance mode.
                      Changes WILL be saved to the base image (use this to pre-install
                      VS Code or run updates).

      pause           Pause the currently running Windows sandbox VM.
                      (You can safely close the SPICE viewer window while paused).

      resume          Resume (unpause) the paused Windows sandbox VM and
                      reopen the viewer if it was closed.

      view            Reopen the SPICE viewer window for a running sandbox VM.

      init [version|iso]
                      Initialize the Windows sandbox.
                      - If an ISO path is provided (e.g. `win-sandbox init ~/Downloads/Win11.iso`),
                        it uses that ISO directly.
                      - If a version is provided (default "11"), it attempts an automated quickget.

      status          Show the status of the Windows sandbox VM and disk images.

      delete          Delete the Windows sandbox VM disk and configuration to reclaim space.

    Options:
      All extra options after the command are passed directly to quickemu.
      Example: win-sandbox run --fullscreen
    EOF
        }

        find_vm_conf() {
          if [ -f "$DEFAULT_VM_CONF" ]; then
            echo "$DEFAULT_VM_CONF"
          else
            local conf
            conf=$(find "$VM_BASE_DIR" -maxdepth 1 -name "*.conf" 2>/dev/null | head -n 1 || true)
            if [ -n "$conf" ]; then
              echo "$conf"
            else
              echo ""
            fi
          fi
        }

        ensure_iso_symlink() {
          local conf="$1"
          local vm_name
          vm_name=$(basename "$conf" .conf)
          local vm_dir="$VM_BASE_DIR/$vm_name"
          local target_iso="$vm_dir/$vm_name.iso"

          if [ ! -f "$target_iso" ]; then
            # Check if user placed any other Windows ISO in vm_dir or VM_BASE_DIR or ~/Downloads
            local found_iso=""
            for search_dir in "$vm_dir" "$VM_BASE_DIR" "$HOME/Downloads"; do
              if [ -d "$search_dir" ]; then
                found_iso=$(find "$search_dir" -maxdepth 1 -name "*[Ww]in*.iso" ! -name "virtio-win.iso" ! -name "unattended.iso" 2>/dev/null | head -n 1 || true)
                if [ -n "$found_iso" ] && [ -f "$found_iso" ]; then
                  echo "Detected downloaded Windows ISO: $found_iso"
                  ln -sf "$(realpath "$found_iso")" "$target_iso"
                  break
                fi
              fi
            done
          fi
        }

        ensure_spice_display() {
          local conf="$1"
          if [ -f "$conf" ] && ! grep -q "^display=" "$conf"; then
            echo 'display="spice"' >> "$conf"
          fi
        }

        is_vm_running() {
          local conf="$1"
          local vm_name
          vm_name=$(basename "$conf" .conf)
          local vm_dir="$VM_BASE_DIR/$vm_name"
          local pid_file="$vm_dir/$vm_name.pid"
          if [ -f "$pid_file" ]; then
            local pid
            pid=$(head -n 1 "$pid_file" 2>/dev/null || echo "")
            if [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null; then
              return 0
            fi
          fi
          return 1
        }

        is_viewer_running() {
          local conf="$1"
          local vm_name
          vm_name=$(basename "$conf" .conf)
          pgrep -f "spicy.*$vm_name" >/dev/null 2>&1
        }

        launch_viewer() {
          local conf="$1"
          local vm_name
          vm_name=$(basename "$conf" .conf)
          local vm_dir="$VM_BASE_DIR/$vm_name"
          local sock="$vm_dir/$vm_name.sock"
          if [ -S "$sock" ]; then
            ${pkgs.spice-gtk}/bin/spicy --uri="spice+unix://$sock" --title "$vm_name" --spice-shared-dir "$HOME" >/dev/null 2>&1 &
          fi
        }

        send_monitor_cmd() {
          local conf="$1"
          local cmd="$2"
          local vm_name
          vm_name=$(basename "$conf" .conf)
          local monitor_sock="$VM_BASE_DIR/$vm_name/$vm_name-monitor.socket"
          if [ -S "$monitor_sock" ]; then
            echo "$cmd" | ${pkgs.socat}/bin/socat -,shut-down UNIX-CONNECT:"$monitor_sock" >/dev/null 2>&1
          else
            echo "Error: Monitor socket not found."
            return 1
          fi
        }

        get_vm_status() {
          local conf="$1"
          if [ -n "$conf" ] && is_vm_running "$conf"; then
            local vm_name
            vm_name=$(basename "$conf" .conf)
            local monitor_sock="$VM_BASE_DIR/$vm_name/$vm_name-monitor.socket"
            if [ -S "$monitor_sock" ]; then
              local stat_line
              stat_line=$(echo "info status" | ${pkgs.socat}/bin/socat -,shut-down UNIX-CONNECT:"$monitor_sock" 2>/dev/null | grep "VM status:" || true)
              if [[ "$stat_line" =~ "paused" ]]; then
                echo "paused"
                return 0
              else
                echo "running"
                return 0
              fi
            else
              echo "running"
              return 0
            fi
          fi
          echo "stopped"
        }

        check_vm_ready() {
          local conf="$1"
          ensure_iso_symlink "$conf"
          ensure_spice_display "$conf"

          local vm_name
          vm_name=$(basename "$conf" .conf)
          local vm_dir="$VM_BASE_DIR/$vm_name"
          local iso="$vm_dir/$vm_name.iso"
          local disk="$vm_dir/disk.qcow2"

          if [ ! -f "$iso" ]; then
            local disk_size=0
            if [ -f "$disk" ]; then
              disk_size=$(stat -c%s "$disk" 2>/dev/null || echo 0)
            fi
            if [ "$disk_size" -lt 1073741824 ]; then
              echo "Error: Installation ISO '$iso' is missing and disk has not been installed yet."
              echo ""
              echo "Microsoft often blocks automated script downloads on university and datacenter networks."
              echo "To complete setup:"
              echo "1. Download the Windows 11 ISO from your browser at: https://www.microsoft.com/en-us/software-download/windows11"
              echo "2. Run: win-sandbox init /path/to/downloaded-windows.iso"
              exit 1
            fi
          fi
        }

        mkdir -p "$VM_BASE_DIR"

        CMD="''${1:-run}"
        shift || true

        case "$CMD" in
          run)
            CONF=$(find_vm_conf)
            if [ -z "$CONF" ]; then
              echo "Error: No Windows VM configuration found in $VM_BASE_DIR."
              echo "Run 'win-sandbox init' first to download and prepare the Windows image."
              exit 1
            fi
            check_vm_ready "$CONF"
            if is_vm_running "$CONF"; then
              echo "Windows sandbox VM is already running."
              if ! is_viewer_running "$CONF"; then
                echo "Reopening SPICE viewer..."
                launch_viewer "$CONF"
              else
                echo "SPICE viewer is already open."
              fi
              exit 0
            fi
            echo "============================================================"
            echo "  🚀 Starting Disposable Windows Session (--status-quo)     "
            echo "  Changes will NOT be saved to disk upon closing.          "
            echo "============================================================"
            exec ${pkgs.quickemu}/bin/quickemu --vm "$CONF" --status-quo "$@"
            ;;

          edit)
            CONF=$(find_vm_conf)
            if [ -z "$CONF" ]; then
              echo "Error: No Windows VM configuration found in $VM_BASE_DIR."
              echo "Run 'win-sandbox init' first to download and prepare the Windows image."
              exit 1
            fi
            check_vm_ready "$CONF"
            echo "============================================================"
            echo "  ⚠️  Starting Maintenance Windows Session                  "
            echo "  Changes WILL be saved to the base disk.                   "
            echo "============================================================"
            exec ${pkgs.quickemu}/bin/quickemu --vm "$CONF" "$@"
            ;;

          pause)
            CONF=$(find_vm_conf)
            if [ -z "$CONF" ]; then
              echo "Error: No Windows VM configuration found in $VM_BASE_DIR."
              exit 1
            fi
            if ! is_vm_running "$CONF"; then
              echo "Error: Windows sandbox VM is not currently running."
              exit 1
            fi
            echo "Pausing Windows sandbox VM..."
            send_monitor_cmd "$CONF" "stop"
            echo "Windows sandbox VM paused."
            ;;

          resume|unpause)
            CONF=$(find_vm_conf)
            if [ -z "$CONF" ]; then
              echo "Error: No Windows VM configuration found in $VM_BASE_DIR."
              exit 1
            fi
            if ! is_vm_running "$CONF"; then
              echo "Error: Windows sandbox VM is not currently running."
              exit 1
            fi
            echo "Resuming Windows sandbox VM..."
            send_monitor_cmd "$CONF" "cont"
            echo "Windows sandbox VM resumed."
            if ! is_viewer_running "$CONF"; then
              echo "Reopening SPICE viewer..."
              launch_viewer "$CONF"
            fi
            ;;

          view|reopen|show)
            CONF=$(find_vm_conf)
            if [ -z "$CONF" ]; then
              echo "Error: No Windows VM configuration found in $VM_BASE_DIR."
              exit 1
            fi
            if ! is_vm_running "$CONF"; then
              echo "Error: Windows sandbox VM is not currently running."
              exit 1
            fi
            if is_viewer_running "$CONF"; then
              echo "SPICE viewer is already open."
            else
              echo "Opening SPICE viewer..."
              launch_viewer "$CONF"
            fi
            ;;

          toggle-pause)
            CONF=$(find_vm_conf)
            if [ -z "$CONF" ] || ! is_vm_running "$CONF"; then
              echo "Error: Windows sandbox VM is not currently running."
              exit 1
            fi
            CURRENT_STATUS=$(get_vm_status "$CONF")
            if [ "$CURRENT_STATUS" = "paused" ]; then
              echo "Resuming Windows sandbox VM..."
              send_monitor_cmd "$CONF" "cont"
              if ! is_viewer_running "$CONF"; then
                launch_viewer "$CONF"
              fi
            else
              echo "Pausing Windows sandbox VM..."
              send_monitor_cmd "$CONF" "stop"
            fi
            ;;

          status-brief)
            CONF=$(find_vm_conf)
            get_vm_status "$CONF"
            exit 0
            ;;

          powerdown|shutdown)
            CONF=$(find_vm_conf)
            if [ -z "$CONF" ] || ! is_vm_running "$CONF"; then
              echo "Error: Windows sandbox VM is not currently running."
              exit 1
            fi
            echo "Sending ACPI shutdown signal..."
            send_monitor_cmd "$CONF" "system_powerdown"
            ;;

          kill)
            CONF=$(find_vm_conf)
            if [ -z "$CONF" ]; then
              echo "Error: No Windows VM configuration found in $VM_BASE_DIR."
              exit 1
            fi
            ${pkgs.quickemu}/bin/quickemu --vm "$CONF" --kill || true
            ;;

          init)
            ARG="''${1:-11}"
            shift || true

            if [ -f "$ARG" ] && [[ "$ARG" == *.iso ]]; then
              echo "Initializing Windows VM using provided ISO: $ARG..."
              cd "$VM_BASE_DIR"
              ${pkgs.quickemu}/bin/quickget windows 11 "$@" || true
              mkdir -p "$VM_BASE_DIR/windows-11"
              ln -sf "$(realpath "$ARG")" "$VM_BASE_DIR/windows-11/windows-11.iso"
              echo "Linked $ARG -> $VM_BASE_DIR/windows-11/windows-11.iso"
            else
              VERSION="$ARG"
              echo "Initializing Windows $VERSION in $VM_BASE_DIR..."
              cd "$VM_BASE_DIR"
              ${pkgs.quickemu}/bin/quickget windows "$VERSION" "$@" || true
              conf="windows-$VERSION.conf"
              iso="windows-$VERSION/windows-$VERSION.iso"
              if [ -f "$conf" ]; then
                ensure_iso_symlink "$conf"
              fi
              if [ ! -f "$iso" ]; then
                echo ""
                echo "=========================================================================="
                echo "  NOTE: Microsoft blocked the automated download request via Sentinel.   "
                echo "  This is normal for university / datacenter IP addresses.                "
                echo ""
                echo "  To finish:"
                echo "  1. Download Windows 11 ISO in your browser:                            "
                echo "     https://www.microsoft.com/en-us/software-download/windows11          "
                echo "  2. Run:                                                                 "
                echo "     win-sandbox init /path/to/downloaded.iso                            "
                echo "=========================================================================="
                exit 1
              fi
            fi
            echo ""
            echo "Initialization complete!"
            echo "1. Run 'win-sandbox edit' to complete the automated Windows install and install VS Code."
            echo "2. Once ready, shut down the VM, and use 'win-sandbox run' for disposable lecture sessions!"
            ;;

          status)
            echo "Sandbox directory: $VM_BASE_DIR"
            CONF=$(find_vm_conf)
            if [ -n "$CONF" ]; then
              echo "Config: $CONF"
              echo "VM Status: $(get_vm_status "$CONF")"
              ${pkgs.quickemu}/bin/quickemu --vm "$CONF" --snapshot info || true
              echo "Disk usage:"
              du -sh "$VM_BASE_DIR" 2>/dev/null || true
            else
              echo "Status: Not initialized. Run 'win-sandbox init' to set up."
            fi
            ;;

          delete)
            CONF=$(find_vm_conf)
            if [ -z "$CONF" ]; then
              echo "No VM found in $VM_BASE_DIR."
              exit 0
            fi
            read -rp "Are you sure you want to delete the Windows VM in $VM_BASE_DIR? [y/N] " confirm
            if [[ "$confirm" =~ ^[Yy]$ ]]; then
              cd "$VM_BASE_DIR"
              ${pkgs.quickemu}/bin/quickemu --vm "$CONF" --delete-vm || true
              rm -rf "$VM_BASE_DIR"
              echo "Deleted."
            else
              echo "Aborted."
            fi
            ;;

          help|-h|--help)
            show_help
            ;;

          *)
            echo "Unknown command: $CMD"
            show_help
            exit 1
            ;;
        esac
  '';

  winSandboxDesktop = pkgs.makeDesktopItem {
    name = "win-sandbox";
    desktopName = "Windows Sandbox (Disposable)";
    comment = "Launch a lightweight, disposable Windows environment";
    icon = "distributor-logo-windows";
    exec = "${winSandbox}/bin/win-sandbox run";
    categories = [
      "System"
      "Utility"
    ];
  };
in
{
  # Enable libvirtd daemon
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = true;
    };
    firewallBackend = "nftables";
  };

  # Ignore unhandled MSRs on AMD KVM for Windows guests
  boot.extraModprobeConfig = ''
    options kvm ignore_msrs=1
    options kvm_amd ignore_msrs=1
  '';

  # Install virtualization tools and disposable Windows sandbox helper
  environment.systemPackages = with pkgs; [
    virt-manager
    quickemu
    spice-gtk
    winSandbox
    winSandboxDesktop
  ];

  # Manage nested virtualization or specific spice protocols (Optional but recommended)
  virtualisation.spiceUSBRedirection.enable = true;

  # Subvolume for VM images: nested subvolume to automatically exclude from btrbk snapshots, with No_COW (+C)
  systemd.tmpfiles.rules = [
    "v /persist/vms 0775 dominik users - -"
    "h /persist/vms - - - - +C"
  ];

  environment.persistence."/persist".directories = [
    "/var/lib/libvirt"
  ];
}
