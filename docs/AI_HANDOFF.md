# Instructions for the AI connected to the user's GitHub and Unraid

Create a public GitHub repository named `hideck-qmi-driver` and push this project to it.

## Required steps

1. Determine the authenticated GitHub owner:

```bash
OWNER="$(gh api user -q .login)"
```

2. Replace every `ashanzzz` placeholder with `$OWNER`.
3. Run local checks:

```bash
bash -n source/resolve-latest-stable.sh
bash -n source/package-output.sh
python3 - <<'PY'
import xml.etree.ElementTree as ET
p='hideck-qmi-driver.plg'
text=open(p, encoding='utf-8').read()
# xml.etree cannot resolve the custom DTD entities without preprocessing;
# perform structural checks that matter for this PLG.
assert '<PLUGIN ' in text and '</PLUGIN>' in text
assert 'ashanzzz' not in text
import re
assert not re.search(r'(?m)^\s*(modprobe\s+--force|insmod\s+-f)\b', text)
print('PLG structural safety checks: OK')
PY
```

4. Create and push repository:

```bash
git init
git branch -M main
git add .
git commit -m "Initial HiDeck QMI driver plugin"
gh repo create "$OWNER/hideck-qmi-driver" --public --source=. --remote=origin --push
```

5. In GitHub Actions, run `build-driver` with `unraid_version=7.3.2` and wait for release `unraid-7.3.2`.
6. Verify the release contains exactly:
   - `hideck-qmi-7.3.2.tar.gz`
   - `hideck-qmi-7.3.2.tar.gz.sha256`
7. Install the plugin on Unraid using the raw `.plg` URL.
8. Confirm:

```bash
hideck-qmi-status
modinfo -F vermagic cdc_wdm
modinfo -F vermagic qmi_wwan
ls -l /dev/cdc-wdm*
ip -br link | grep -Ei 'wwan|wwp'
```

9. Confirm HiDeck still shows protocol `QMI`, interface `wwan0`, and eUICC/Profile data.
10. Only after the plugin works across a reboot, remove any old `/boot/config/go` QMI-loading block so there is one owner of driver persistence.

## Upgrade test

Before upgrading Unraid, check whether a release exists for the target version. Do not force-load old modules on a new kernel. If the release is absent, run the workflow for the target version first.
