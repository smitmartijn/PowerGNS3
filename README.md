# PowerGNS3

## Example Usage

### Connect to GNS3 API

```
PS PowerGNS3> Import-Module ./PowerGNS3.psm1
PS PowerGNS3> Connect-GNS3Server -Server 10.196.164.186 -Port 3080

PowerShell credential request
GNS3 Authentication
User: admin
Password for user admin: ********


Server              GNS3Version Credentials
------              ----------- -----------
10.196.164.186:3080 2.2.7       System.Management.Automation.PSCredential
```

### List projects

```
PS PowerGNS3> Get-GNS3Project

auto_close            : False
auto_open             : False
auto_start            : False
filename              : DEMO.gns3
name                  : DEMO
path                  : /opt/gns3/projects/a1af8eaf-3dc4-47e6-88af-decdf07a9c30
project_id            : a1af8eaf-3dc4-47e6-88af-decdf07a9c30
status                : opened
..snip..
```

### List nodes inside projects

```
PS PowerGNS3> $project = (Get-GNS3Project | where {$_.name -eq "DEMO"})
PS PowerGNS3> Get-GNS3ProjectNodes -Project $project

command_line       : /usr/bin/qemu-system-x86_64 -name bb-ny-2 -m 4096M -smp cpus=1 -enable-kvm -machine smm=off -boot order=c -drive file=/opt/gns3/projects/a1af8eaf-3dc4-47e6-88af-decdf07a9c30/project-files/qemu/5978b9de-fc5e-4418-9ec7-11bcc265d1c9/hda_disk.qcow2,if=ide,index=0,media=disk,id=drive0 -drive file=/opt/gns3/projects/a1af8eaf-3dc4-47e6-88af-decdf07a9c30/project-files/qemu/5978b9de-fc5e-4418-9ec7-11bcc265d1c9/hdb_disk.qcow2,if=ide,index=1,media=disk,id=drive1 -uuid 5978b9de-fc5e-4418-9ec7-11bcc265d1c9 -serial telnet:127.0.0.1:5000,server,nowait -monitor tcp:127.0.0.1:41261,server,nowait -net none -device virtio-net-pci,mac=0c:9c:30:d1:c9:00,netdev=gns3-0 -netdev socket,id=gns3-0,udp=127.0.0.1:20275,localaddr=127.0.0.1:20274 -device virtio-net-pci,mac=0c:9c:30:d1:c9:01,netdev=gns3-1 -netdev socket,id=gns3-1,udp=127.0.0.1:20277,localaddr=127.0.0.1:20276 -device virtio-net-pci,mac=0c:9c:30:d1:c9:02,netdev=gns3-2 -netdev socket,id=gns3-2,udp=127.0.0.1:20279,localaddr=127.0.0.1:20278 -device virtio-net-pci,mac=0c:9c:30:d1:c9:03,netdev=gns3-3 -netdev socket,id=gns3-3,udp=127.0.0.1:20281,localaddr=127.0.0.1:20280 -device virtio-net-pci,mac=0c:9c:30:d1:c9:04,netdev=gns3-4 -netdev socket,id=gns3-4,udp=127.0.0.1:20283,localaddr=127.0.0.1:20282 -device virtio-net-pci,mac=0c:9c:30:d1:c9:05,netdev=gns3-5 -netdev socket,id=gns3-5,udp=127.0.0.1:20285,localaddr=127.0.0.1:20284 -device virtio-net-pci,mac=0c:9c:30:d1:c9:06,netdev=gns3-6 -netdev socket,id=gns3-6,udp=127.0.0.1:20287,localaddr=127.0.0.1:20286 -device virtio-net-pci,mac=0c:9c:30:d1:c9:07,netdev=gns3-7 -netdev socket,id=gns3-7,udp=127.0.0.1:20289,localaddr=127.0.0.1:20288 -device virtio-net-pci,mac=0c:9c:30:d1:c9:08,netdev=gns3-8 -netdev socket,id=gns3-8,udp=127.0.0.1:20291,localaddr=127.0.0.1:20290 -device virtio-net-pci,mac=0c:9c:30:d1:c9:09,netdev=gns3-9 -netdev socket,id=gns3-9,udp=127.0.0.1:20293,localaddr=127.0.0.1:20292 -device virtio-net-pci,mac=0c:9c:30:d1:c9:0a,netdev=gns3-10 -netdev socket,id=gns3-10,udp=127.0.0.1:20295,localaddr=127.0.0.1:20294 -device virtio-net-pci,mac=0c:9c:30:d1:c9:0b,netdev=gns3-11 -netdev socket,id=gns3-11,udp=127.0.0.1:20297,localaddr=127.0.0.1:20296 -device virtio-net-pci,mac=0c:9c:30:d1:c9:0c,netdev=gns3-12 -netdev socket,id=gns3-12,udp=127.0.0.1:20299,localaddr=127.0.0.1:20298 -display none
compute_id         : 0fab9ff8-1cc4-4933-aead-825fd60d9a4f
console            : 5004
console_auto_start : False
console_host       : 10.196.164.187
console_type       : telnet
custom_adapters    : {}
first_port_name    : Management1
height             : 60
label              : @{rotation=0; style=font-family: TypeWriter;font-size: 10.0;font-weight: bold;fill: #000000;fill-opacity: 1.0;; text=bb-ny-2; x=0; y=-25}
locked             : False
name               : bb-ny-2
node_directory     : /opt/gns3/projects/a1af8eaf-3dc4-47e6-88af-decdf07a9c30/project-files/qemu/5978b9de-fc5e-4418-9ec7-11bcc265d1c9
node_id            : 5978b9de-fc5e-4418-9ec7-11bcc265d1c9
node_type          : qemu
port_name_format   : Ethernet{port1}
port_segment_size  : 0
ports              : {@{adapter_number=0; adapter_type=virtio-net-pci; data_link_types=; link_type=ethernet; mac_address=0c:9c:30:d1:c9:00; name=Management1; port_number=0; short_name=Management1}, @{adapter_number=1; adapter_type=virtio-net-pci; data_link_types=; link_type=ethernet; mac_addre
                     ss=0c:9c:30:d1:c9:01; name=Ethernet1; port_number=0; short_name=Ethernet1}, @{adapter_number=2; adapter_type=virtio-net-pci; data_link_types=; link_type=ethernet; mac_address=0c:9c:30:d1:c9:02; name=Ethernet2; port_number=0; short_name=Ethernet2}, @{adapter_number=3; adapt
                     er_type=virtio-net-pci; data_link_types=; link_type=ethernet; mac_address=0c:9c:30:d1:c9:03; name=Ethernet3; port_number=0; short_name=Ethernet3}…}
project_id         : a1af8eaf-3dc4-47e6-88af-decdf07a9c30
properties         : @{adapter_type=virtio-net-pci; adapters=13; bios_image=; bios_image_md5sum=; boot_priority=c; cdrom_image=; cdrom_image_md5sum=; cpu_throttling=0; cpus=1; hda_disk_image=Aboot-veos-serial-8.0.0.iso; hda_disk_image_md5sum=187ef8e0f95bec69c5974417515ad13c; hda_disk_interface
                     =ide; hdb_disk_image=vEOS-lab-4.23.0.1F.vmdk; hdb_disk_image_md5sum=932d24ac812744ab1bc9ce2c3a915949; hdb_disk_interface=ide; hdc_disk_image=; hdc_disk_image_md5sum=; hdc_disk_interface=ide; hdd_disk_image=; hdd_disk_image_md5sum=; hdd_disk_interface=ide; initrd=; initrd_m
                     d5sum=; kernel_command_line=; kernel_image=; kernel_image_md5sum=; legacy_networking=False; linked_clone=True; mac_address=0c:9c:30:d1:c9:00; on_close=power_off; options=; platform=x86_64; process_priority=normal; qemu_path=/usr/bin/qemu-system-x86_64; ram=4096; usage=The
                     login is admin, with no password by default}
status             : started
symbol             : :/symbols/affinity/circle/blue/switch_multilayer.svg
template_id        : a40870cc-9dd9-48d7-a83a-5a0b2c57f82b
width              : 60
x                  : -228
y                  : -142
z                  : 1

command_line       : /usr/bin/qemu-system-x86_64 -name bb-prdc-2 -m 4096M -smp cpus=1 -enable-kvm -machine smm=off -boot order=c -drive file=/opt/gns3/projects/a1af8eaf-3dc4-47e6-88af-decdf07a9c30/project-files/qemu/e31e6fda-c439-4d21-b627-ee9135189f2d/hda_disk.qcow2,if=ide,index=0,media=disk,
                     id=drive0 -drive file=/opt/gns3/projects/a1af8eaf-3dc4-47e6-88af-decdf07a9c30/project-files/qemu/e31e6fda-c439-4d21-b627-ee9135189f2d/hdb_disk.qcow2,if=ide,index=1,media=disk,id=drive1 -uuid e31e6fda-c439-4d21-b627-ee9135189f2d -serial telnet:127.0.0.1:5001,server,nowait -
                     monitor tcp:127.0.0.
..snip..
```

# Stop a node in a project

```
PS PowerGNS3> Get-GNS3Project | where {$_.name -eq "DEMO"} | Get-GNS3ProjectNodes | where {$_.name -eq "bb-ny-2"} | Stop-GNS3ProjectNode

..snip..
name               : bb-ny-2
status             : stopped
..snip..
```

# Start a node in a project

```
PS PowerGNS3> Get-GNS3Project | where {$_.name -eq "DEMO"} | Get-GNS3ProjectNodes | where {$_.name -eq "bb-ny-2"} | Start-GNS3ProjectNode

..snip..
name               : bb-ny-2
status             : stopped
..snip..
```