#!/bin/bash
cat ./machineconfig.yaml | op inject | talosctl --nodes $(op read op://Cloudlab/talos/CP1_IPV4) apply-config -f /dev/stdin
