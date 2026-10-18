# HiDeck QMI Driver for Unraid

Unraid plugin that installs `cdc_wdm` and `qmi_wwan` for the exact Unraid release so HiDeck can use `/dev/cdc-wdmX` and QMI UIM for eSIM/eUICC management.

## Why this exists

Some Unraid releases do not ship `cdc_wdm` / `qmi_wwan`, even though cellular modems such as the Quectel EC25 expose a QMI USB interface. Without these modules there is no `/dev/cdc-wdm0`, so HiDeck falls back to AT logical-channel commands. Older EC25 firmware can reject that AT path even though QMI UIM works.

## Safety model

- Bundles are built for one exact Unraid release.
- Each bundle records its exact kernel release.
- SHA-256 is verified before extraction.
- `modinfo -F vermagic` must equal the running `uname -r` for both modules.
- No `--force`, `insmod -f`, or cross-kernel loading.
- If a new Unraid version has no driver release yet, the plugin fails safely. Unraid still boots; HiDeck QMI/eSIM simply remains unavailable until a matching build is published.
- If a future Unraid release ships both modules itself, the plugin prefers those stock modules.

## Release naming

GitHub Release tag:

```text
unraid-7.3.2
```

Assets:

```text
hideck-qmi-7.3.2.tar.gz
hideck-qmi-7.3.2.tar.gz.sha256
```

The bundle contains `manifest.env`, `cdc-wdm.ko`, and `qmi_wwan.ko`.

## Build a release

Open **Actions -> build-driver -> Run workflow** and enter the Unraid version, for example `7.3.2`.

The workflow uses `gameonwhales/unraid-module-builder` with:

```text
CONFIG_USB_WDM=m
CONFIG_USB_NET_QMI_WWAN=m
```

It publishes a release only after both modules have matching vermagic.

The scheduled workflow checks the latest stable Unraid release daily and skips work when its release already exists.

## Install

After the release for your Unraid version exists, install this URL in **Plugins -> Install Plugin**:

```text
https://raw.githubusercontent.com/ashanzzz/hideck-qmi-driver/main/hideck-qmi-driver.plg
```

Then run:

```bash
hideck-qmi-status
```

Expected on a Quectel EC25 in QMI mode:

```text
qmi_wwan
cdc_wdm
/dev/cdc-wdm0
wwan0
```

## Unraid upgrade behavior

On Unraid versions that expose the `os_update` event, the plugin attempts to cache the bundle for the incoming Unraid version before reboot. If no release exists yet, it sends a warning notification instead of loading an incompatible driver.

For production use, wait until the GitHub release for the target Unraid version exists before rebooting into the update.

## HiDeck

HiDeck should be configured with:

```yaml
device_backend: qmi
esim_transport: qmi
```

Runtime paths such as `/dev/cdc-wdm0`, `wwan0`, and the AT port should be discovered by HiDeck rather than persisted manually.

## License

MIT
